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

        #Show tenants
        def index(options = {})
          path = base_uri
          request(path, options).to_json
        end

        #Gets a tenant
        def find_by_id(id, debug = false)
          path = "#{base_uri}/#{id}"
          request(path, { debug: debug })
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToRetrieveTenantsError)
            .to_hash
        end

        # Creates a new tenant
        def create(tenant_body, options = {})
          path = base_uri
          request(path, options.merge(method: :post), tenant_body).if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
            .to_hash
        end

        # Updates a tenant
        def update_by_id(id, body)
          path = "#{base_uri}/#{id}"
          request(path, { method: :post }, body).if_404_raise(Cdris::Gateway::Exceptions::UnableToRetrieveTenantsError)
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToUpdateTenantError)
            .to_hash
        end

        # Gets the base URI for a tenant
        #
        # @return [String] the base URI for a tenant
        def base_uri
          "#{api}/admin/tenants"
        end
      end
    end
  end
end
