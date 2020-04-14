require 'neutrino/gateway/requestor'
require 'neutrino/gateway/exceptions'

module Neutrino
  module Gateway
    class Info < Neutrino::Gateway::Requestor
      private_class_method :new
      class << self

        # Gets the deployments of NEUTRINO
        #
        # @return [Hash] the deployments
        # @raise [Exceptions::UnableToParseVersionHistoryError] when NEUTRINO returns a 400 status code
        def deployments
          path = "#{base_uri}/deployments"
          request(path).if_400_raise(Neutrino::Gateway::Exceptions::UnableToParseVersionHistoryError)
                       .to_hash
        end

        # Gets information about the current deployment of NEUTRINO
        #
        # @return [Hash] info about the current deployment
        # @raise [Exceptions::UnableToParseVersionInformationError] when NEUTRINO returns a 400 status code
        def current_deployment
          path = "#{base_uri}/deployment/current"
          request(path).if_400_raise(Neutrino::Gateway::Exceptions::UnableToParseVersionInformationError)
                       .to_hash
        end

        # Gets information about the current configuration of NEUTRINO
        #
        # @param [String] category the category of configuration to get, if omitted gets all categories
        # @return [Hash] information about the requested configuration(s)
        # @raise [Exceptions::UnableToRetrieveConfigurations] when NEUTRINO returns a 400 status code
        def configuration(category = nil, options = {})
          path = "#{base_uri}/configuration#{category ? '/'+category : ''}"
          request(path, options)
                        .if_404_raise(Neutrino::Gateway::Exceptions::MissingConfiguration.new)
                        .if_400_raise(Neutrino::Gateway::Exceptions::UnableToRetrieveConfigurations)
                       .to_hash
        end

        # Gets the base URI for NEUTRINO information
        #
        # @return [String] the base URI for NEUTRINO information
        def base_uri
          '/cdris'
        end
      end
    end
  end
end
