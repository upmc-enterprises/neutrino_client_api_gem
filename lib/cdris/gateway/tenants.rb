require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class Tenants < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # Gets the tenants of CDRIS
        #
        # @return [Hash] the tenants
        # @raise [Exceptions::UnableToRetrieveTenantsError] when CDRIS returns a 400 status code
        def get
          path = "#{self.api}/admin/tenants"
          request(path).if_400_raise(Cdris::Gateway::Exceptions::UnableToRetrieveTenantsError).to_hash
        end

      end
    end
  end
end
