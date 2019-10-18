require 'neutrino/gateway/requestor'
require 'neutrino/gateway/exceptions'

module Neutrino
  module Gateway
    class ApplicationAccounts < Neutrino::Gateway::Requestor
      private_class_method :new
      class << self

        # Creates an application account of Neutrino
        #
        # @return [Hash] an application account
        # @raise [Exceptions::UnableToCreateApplicationAccountsError] when Neutrino returns a 400 status code
        def create(body)
          response = request(base_uri, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Neutrino::Gateway::Exceptions::UnableToCreateApplicationAccountsError.new([], error))
            .to_hash
        end

        # Gets the application accounts of Neutrino
        #
        # @return [Hash] the application accounts
        # @raise [Exceptions::UnableToRetrieveApplicationAccountsError] when Neutrino returns a 400 status code
        def index
          request(base_uri)
            .if_400_raise(Neutrino::Gateway::Exceptions::UnableToRetrieveApplicationAccountsError)
            .to_hash
        end

        # Finds an application account of Neutrino by its ID
        #
        # @return [Hash] the application account
        # @raise [Exceptions::UnableToRetrieveApplicationAccountsError] when Neutrino returns a 400 status code
        def find_by_id(id, debug = false)
          path = "#{base_uri}/#{id}"
          request(path, { debug: debug })
            .if_400_raise(Neutrino::Gateway::Exceptions::UnableToRetrieveApplicationAccountsError)
            .to_hash
        end

        # Updates an application account of Neutrino by its ID
        #
        # @return [Hash] the application account
        # @raise [Exceptions::UnableToUpdateApplicationAccountsError] when Neutrino returns a 400 status code
        def update_by_id(id, body)
          path = "#{base_uri}/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Neutrino::Gateway::Exceptions::UnableToUpdateApplicationAccountsError.new([], error))
            .to_hash
        end

        def base_uri
          "#{api}/admin/application_accounts"
        end
      end
    end
  end
end
