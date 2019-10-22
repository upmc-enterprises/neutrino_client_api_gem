require 'api-auth'
require 'net/http'
require 'net/http/post/multipart'
require 'neutrino/helpers/api_auth_modifications.rb'
require 'neutrino/helpers/monkey_patch'
require 'neutrino/gateway/exceptions'
require 'digest/sha2'

module Neutrino
  module Api
    class Client

      DEFAULT_API_VERSION = '1'

      private_class_method :new

      class << self

        # Stores and persists configuration information for the client to use in making
        #   calls to NEUTRINO
        #
        # @param [Hash] config of symbolic keys to use to make requests
        # @return [Hash] the config
        def config=(config)
          @config = symbolize_keys(config)
        end

        # Gets the configuration
        #
        # @return [Hash] the config
        def config
          @config ||= {}
        end

        # Gets the protocol
        #
        # @return [Object] the protocol
        def protocol
          @config[:protocol]
        end

        # Gets the host
        #
        # @return [Object] the host
        def host
          @config[:host]
        end

        # Gets the port
        #
        # @return [Object] the port
        def port
          @config[:port]
        end

        # Gets the user root
        #
        # @return [Object] the user root
        def user_root
          @config[:user_root]
        end

        # Gets the user extension
        #
        # @return [Object] the user extension
        def user_extension
          @config[:user_extension]
        end

        # Whether the config is nil or it does not contain some specified key
        #
        # @param [Symbol] key to check for in config
        # @return [Boolean] `true` if the specified key is in config, `false` otherwise
        def config_nil_or_doesnt_contain?(key)
          @config.nil? || @config[key].nil?
        end

        # Gets the auth user
        #
        # @return [Object] the auth user
        def auth_user
          @config[:auth_user]
        end

        # Gets the auth password
        #
        # @return [Object] the auth password
        def auth_pass
          @config[:auth_pass]
        end

        # Gets the HMAC ID
        #
        # @return [Object] the HMAC ID
        def hmac_id
          @config[:hmac_id]
        end

        # Gets the HMAC key
        #
        # @return [Object] the HMAC key
        def hmac_key
          @config[:hmac_key]
        end

        # Gets the Tenant ID
        #
        # @return [Object] the Tenant ID
        def tenant_id
          @config[:tenant_id]
        end

        # Gets the Tenant key
        #
        # @return [Object] the Tenant key
        def tenant_key
          @config[:tenant_key]
        end

        # Gets the API version
        #
        # @return [Object] the API version
        def api_version
          if config_nil_or_doesnt_contain?(:api_version)
            return DEFAULT_API_VERSION
          end
          @config[:api_version]
        end

        # Gets and sets the base URI for NEUTRINO
        #
        # @return [String] the base URI for NEUTRINO
        def base_uri
          @base_uri ||= "#{protocol}://#{host}:#{port}"
        end

        # Gets the user root and extension in a `Hash`
        #
        # @return [Hash] the user and extension specified by `:user`
        def user_root_and_extension
          {
            user: {
              root: user_root,
              extension: user_extension
            }
          }
        end

        # Performs a request on the NEUTRINO API
        #
        # @param [String] path to make the request against
        # @param [Hash] options query parameters
        # @param [String] body of the request
        # @param [Boolean] basic_auth specifies whether to use basic authentication
        # @param [Integer] http_timeout Response timeout seconds, defaults to 60
        # @return [Net::HTTPResponse] the response from the request
        # @raise [Exceptions::InternalServerError] when the NEUTRINO API responds with 500 code
        def perform_request(path, options = {}, body = nil, basic_auth = false, http_timeout = 60)
          build_request("#{base_uri}#{path}", options, body, basic_auth, http_timeout)
        end

        # Builds a REST request to be sent to the NEUTRINO API.
        #   Tenant id is added if specified in the configuration.  If the tenant
        #   id is added to the request, the HMAC key is created by taking a SHA2-512
        #   bit hash of the application key and the tenant key.
        # @param [String] path Path of NEUTRINO API from which to request information.
        # @param [Hash] options Optional parameters required by request.
        # @param [String] body HTTP body to be transmitted, if any.
        # @param [Boolean] basic_auth Whether or now basic_auth should be used in lieu of HMAC, default false.
        # @param [Integer] http_timeout Response timeout seconds.
        # @return [Http::Response] response from the NEUTRINO API service
        # @raise [Exception] if a request raises either an Errno::ECONNREFUSED or an OpenSSL::SSLError exception
        def build_request(path, options = {}, body = nil, basic_auth = false, http_timeout = nil)
          Net::HTTP.start(host, port, use_ssl: protocol == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE, read_timeout: http_timeout) do |http|
            request_klass = get_method(options)
            tenant_is_from_configuration = false

            options = options.reject { |x| x == :method } if options[:method]

            if tenant_configured? && options[:tid].nil?
              options[:tid] = tenant_id
              tenant_is_from_configuration = true
            end

            uri = URI(path_with_params(path, options))
            if request_klass == Net::HTTP::Post::Multipart
              request = request_klass.new(uri.request_uri, body)
              # If body is not set ApiAuth signing won't get the content md5 right
              # And multipart places the content in body_steam as a stream object
              # So read the stream and set body
              request.body = request.body_stream.read
            else
              request = request_klass.new(uri.request_uri)
            end

            if request_klass == Net::HTTP::Post
              request.content_type = 'application/json'
              request.body = body.to_json
            end

            request.basic_auth(auth_user, auth_pass) if basic_auth

            unless basic_auth || app_hmac_not_configured?
              request = ApiAuth.sign!(request,
                                      hmac_id,
                                      generate_hmac_key(tenant_is_from_configuration))
            end

            http.request(request)
          end
        rescue Errno::ECONNREFUSED, OpenSSL::SSL::SSLError
          raise 'Connection refused'
        end

        # Gets the HTTP method as specified in passed options
        #
        # @param [Hash] options contain methods
        # @return [HTTPRequest] the HTTP method specified in `options`, defaults to `Get`
        def get_method(options)
          return Net::HTTP::Get if options[:method].nil?
          case options[:method]
            when :post_multipart
              Net::HTTP::Post::Multipart
            when :post
              Net::HTTP::Post
            when :delete
              Net::HTTP::Delete
            when :get
              Net::HTTP::Get
          end
        end

        # Provides the RESTFUL path and parameters for a call to the NEUTRINO CORE API
        # @return [String] The API path and parameters to be passed to the NEUTRINO CORE API
        def path_with_params(path, params)
          "#{path}?#{params.merge(user_root_and_extension).gateway_to_query}"
        end

        # Gets a new `Hash` with symbols as keys
        #
        # @param [Hash] a_hash whose keys ought to be converted to symbols
        # @return [Hash] a new `Hash` with symbols as keys
        def symbolize_keys(a_hash)
          return a_hash unless a_hash
          hash_with_symbols = {}
          a_hash.each { |key, value| hash_with_symbols[key.to_sym] = value }
          hash_with_symbols
        end

        private

        # Checks the configuration to see if the application hmac was not configured
        #
        # @return [Boolean] true if hmac was not configured, false hmac if is was configured
        def app_hmac_not_configured?
          if config_nil_or_doesnt_contain?(:hmac_id) || config_nil_or_doesnt_contain?(:hmac_key)
            true
          else
            false
          end
        end

        # Checks the configuration to see if the tenant is configured
        #
        # @return [Boolean] true if tenant is configured, false if not
        def tenant_configured?
          if config_nil_or_doesnt_contain?(:tenant_id) || config_nil_or_doesnt_contain?(:tenant_key)
            false
          else
            true
          end
        end

        # Generates the HMAC key depending on the configuration of the gem.
        #
        # @param [Boolean] configured the tenant id and tenant key are
        #   present in the configuration file.
        # @return [String] a string that is HMAC key
        def generate_hmac_key(tid_is_not_from_request)
          if tenant_configured? && tid_is_not_from_request
            Digest::SHA512.new.update(hmac_key + tenant_key).digest
          else
            hmac_key
          end
        end

      end

    end
  end
end
