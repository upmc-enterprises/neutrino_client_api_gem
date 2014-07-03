require 'cdris/gateway/exceptions'
require 'cdris/api/client'
require 'cdris/gateway/responses/response_handler'

module Cdris
  module Gateway
    class Requestor

      # Gets the base URI for CDRIS with the version specified in `Cdris::Api::Client.config`
      #
      # @param [Hash] options whichmay specify `debug: true`
      # @return [String] the base URI for CDRIS
      def self.api(options = {})
        "/api/v#{Cdris::Api::Client.api_version}#{options[:debug] ? '/debug/true' : ''}"
      end

      # Performs a request against the CDRIS API
      #
      # @param [Hash] path the URI to request
      # @param [Hash] options specify query values
      # @param [String] body the body of the request
      # @param [Boolean] basic_auth whether to use basic authentication
      # @return [Responses::ResponseHandler] a `ResponseHandler` instance for handling response codes
      def self.request(path, options = {}, body = nil, basic_auth = false)
        response = Cdris::Api::Client.perform_request(path, options, body, basic_auth)

        Responses::ResponseHandler.new.
          considering(response).
          if_500_raise(Exceptions::InternalServerError).
          if_non_200_raise(Exceptions::FailedRequestError)
      end
    end
  end
end
