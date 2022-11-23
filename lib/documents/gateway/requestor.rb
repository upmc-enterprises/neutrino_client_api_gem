require 'documents/gateway/exceptions'
require 'documents/api/client'
require 'documents/gateway/responses/response_handler'

module Documents
  module Gateway
    class Requestor

      # Gets the base URI for DOCUMENTS with the version specified in `Documents::Api::Client.config`
      #
      # @param [Hash] options which may specify `debug: true`
      # @return [String] the base URI for DOCUMENTS
      def self.api(options = {})
        "/api/v#{Documents::Api::Client.api_version}#{options[:debug] ? '/debug/true' : ''}"
      end

      # Performs a request against the DOCUMENTS API
      #
      # @param [Hash] path the URI to request
      # @param [Hash] options specify query values
      # @param [String] body the body of the request
      # @param [Boolean] basic_auth whether to use basic authentication
      # @param [Integer] http_timeout Response timeout seconds
      # @return [Responses::ResponseHandler] a `ResponseHandler` instance for handling response codes
      def self.request(path, options = {}, body = nil, basic_auth = false, http_timeout = nil)
        response = Documents::Api::Client.perform_request(path, options, body, basic_auth, http_timeout)
        Responses::ResponseHandler.new.
          considering(response).
          if_500_raise(Exceptions::InternalServerError).
          with_general_exception_check('403', /tenant.*disabled|disabled.*tenant/i,
                                       Documents::Gateway::Exceptions::TenantDisabledError).
          if_non_200_raise(Exceptions::FailedRequestError)
      end
    end
  end
end
