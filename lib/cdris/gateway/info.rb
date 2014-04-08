require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class Info < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # Gets the deployments of CDRIS
        #
        # @return [Hash] the deployments
        # @raise [Exceptions::UnableToParseVersionHistoryError] when CDRIS returns a 400 status code
        def deployments
          path = "#{base_uri}/deployments"
          request(path).if_400_raise(Cdris::Gateway::Exceptions::UnableToParseVersionHistoryError)
                       .to_hash
        end

        # Gets information about the current deployment of CDRIS
        #
        # @return [Hash] info about the current deployment
        # @raise [Exceptions::UnableToParseVersionInformationError] when CDRIS returns a 400 status code
        def current_deployment
          path = "#{base_uri}/deployment/current"
          request(path).if_400_raise(Cdris::Gateway::Exceptions::UnableToParseVersionInformationError)
                       .to_hash
        end

        # Gets information about the current configuration of CDRIS
        #
        # @param [String] category the category of configuration to get, if omitted gets all categories
        # @return [Hash] information about the requested configuration(s)
        # @raise [Exceptions::UnableToRetrieveConfigurations] when CDRIS returns a 400 status code
        def configuration(category = nil)
          path = "#{base_uri}/configuration#{category ? '/'+category : ''}"
          request(path).if_400_raise(Cdris::Gateway::Exceptions::UnableToRetrieveConfigurations)
                       .to_hash
        end

        # Gets the base URI for CDRIS information
        #
        # @return [String] the base URI for CDRIS information
        def base_uri
          '/cdris'
        end
      end
    end
  end
end
