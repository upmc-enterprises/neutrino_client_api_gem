require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class ApplicationAccounts < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # Gets the application accounts of CDRIS
        #
        # @return [Hash] the application accounts
        # @raise [Exceptions::UnableToRetrieveApplicationAccountsError] when CDRIS returns a 400 status code
        def get
          path = "#{self.api}/admin/application_accounts"
          request(path).if_400_raise(Cdris::Gateway::Exceptions::UnableToRetrieveApplicationAccountsError).to_hash
        end

      end
    end
  end
end
