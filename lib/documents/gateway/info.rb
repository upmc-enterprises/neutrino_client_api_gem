require 'documents/gateway/requestor'
require 'documents/gateway/exceptions'

module Documents
  module Gateway
    class Info < Documents::Gateway::Requestor
      private_class_method :new
      class << self

        # Gets the deployments of DOCUMENTS
        #
        # @return [Hash] the deployments
        # @raise [Exceptions::UnableToParseVersionHistoryError] when DOCUMENTS returns a 400 status code
        def deployments(options = {})
          path = "#{base_uri}/deployments"
          request(path, options).if_400_raise(Documents::Gateway::Exceptions::UnableToParseVersionHistoryError)
                       .to_hash
        end

        # Gets information about the current deployment of DOCUMENTS
        #
        # @return [Hash] info about the current deployment
        # @raise [Exceptions::UnableToParseVersionInformationError] when DOCUMENTS returns a 400 status code
        def current_deployment(options = {})
          path = "#{base_uri}/deployment/current"
          request(path, options).if_400_raise(Documents::Gateway::Exceptions::UnableToParseVersionInformationError)
                       .to_hash
        end

        # Gets information about the current configuration of DOCUMENTS
        #
        # @param [String] category the category of configuration to get, if omitted gets all categories
        # @return [Hash] information about the requested configuration(s)
        # @raise [Exceptions::UnableToRetrieveConfigurations] when DOCUMENTS returns a 400 status code
        def configuration(category = nil, options = {})
          path = "#{base_uri}/configuration#{category ? '/'+category : ''}"
          request(path, options)
                        .if_404_raise(Documents::Gateway::Exceptions::MissingConfiguration.new)
                        .if_400_raise(Documents::Gateway::Exceptions::UnableToRetrieveConfigurations)
                       .to_hash
        end

        # Gets the base URI for DOCUMENTS information
        #
        # @return [String] the base URI for DOCUMENTS information
        def base_uri
          '/documents_service'
        end
      end
    end
  end
end
