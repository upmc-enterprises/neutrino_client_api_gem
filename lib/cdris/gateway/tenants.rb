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
        def find_by_id(params, options = {})
          path = "#{base_uri}/#{params[:id]}"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::TenantNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
            .to_hash
        end

        # Creates a new tenant
        def create(tenant_body, options = {})
          path = base_uri
          request(path, options.merge(method: :post), tenant_body).if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
            .to_hash
        end

        # Enable an existing tenant's tenant enabled
        def enable_tenant_by_id(params, options = {})
          path = "#{base_uri}/tenant_enable/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Cdris::Gateway::Exceptions::TenantNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
            .to_hash
        end

        # Disable an existing tenant's tenant enabled
        def disable_tenant_by_id(params, options = {})
          path = "#{base_uri}/tenant_disable/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Cdris::Gateway::Exceptions::TenantNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
            .to_hash
        end

        # Enable an existing tenant's indexing enabled
        def enable_indexing_by_id(params, options = {})
          path = "#{base_uri}/indexing_enable/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Cdris::Gateway::Exceptions::TenantNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
            .to_hash
        end

        # Disable an existing tenant's indexing enabled
        def disable_indexing_by_id(params, options = {})
          path = "#{base_uri}/indexing_disable/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Cdris::Gateway::Exceptions::TenantNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
            .to_hash
        end

        # Enable an existing tenant's gi enabled
        def enable_gi_by_id(params, options = {})
          path = "#{base_uri}/gi_enable/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Cdris::Gateway::Exceptions::TenantNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
            .to_hash
        end

        # Disable an existing tenant's gi enabled
        def disable_gi_by_id(params, options = {})
          path = "#{base_uri}/gi_disable/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Cdris::Gateway::Exceptions::TenantNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
            .to_hash
        end

        # Enable an existing tenant's hf reveal enabled
        def enable_hf_reveal_by_id(params, options = {})
          path = "#{base_uri}/hf_reveal_enable/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Cdris::Gateway::Exceptions::TenantNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
            .to_hash
        end

        # Disable an existing tenant's hf reveal enabled
        def disable_hf_reveal_by_id(params, options = {})
          path = "#{base_uri}/hf_reveal_disable/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Cdris::Gateway::Exceptions::TenantNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::TenantInvalidError)
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
