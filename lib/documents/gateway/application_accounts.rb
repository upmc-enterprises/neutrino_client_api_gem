require 'documents/gateway/requestor'
require 'documents/gateway/exceptions'

module Documents
  module Gateway
    class ApplicationAccounts < Documents::Gateway::Requestor
      private_class_method :new
      class << self

        # Creates an application account of Documents
        #
        # @return [Hash] an application account
        # @raise [Exceptions::UnableToCreateApplicationAccountsError] when Documents returns a 400 status code
        def create(body, options = {})
          response = request(base_uri, options.merge(method: :post), body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Documents::Gateway::Exceptions::UnableToCreateApplicationAccountsError.new([], error))
            .to_hash
        end

        # Gets the application accounts of Documents
        #
        # @return [Hash] the application accounts
        # @raise [Exceptions::UnableToRetrieveApplicationAccountsError] when Documents returns a 400 status code
        def index(options = {})
          request(base_uri, options)
            .if_400_raise(Documents::Gateway::Exceptions::UnableToRetrieveApplicationAccountsError)
            .to_hash
        end

        # Finds an application account of Documents by its ID
        #
        # @return [Hash] the application account
        # @raise [Exceptions::UnableToRetrieveApplicationAccountsError] when Documents returns a 400 status code
        def find_by_id(id, options = {}, debug = false)
          path = "#{base_uri}/#{id}"
          request(path, options.merge(debug: debug))
            .if_400_raise(Documents::Gateway::Exceptions::UnableToRetrieveApplicationAccountsError)
            .to_hash
        end

        # Updates an application account of Documents by its ID
        #
        # @return [Hash] the application account
        # @raise [Exceptions::UnableToUpdateApplicationAccountsError] when Documents returns a 400 status code
        def update_by_id(id, body, options = {})
          path = "#{base_uri}/#{id}"
          response = request(path, options.merge(method: :post), body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Documents::Gateway::Exceptions::UnableToUpdateApplicationAccountsError.new([], error))
            .to_hash
        end

        def base_uri
          "#{api}/admin/application_accounts"
        end
      end
    end
  end
end
