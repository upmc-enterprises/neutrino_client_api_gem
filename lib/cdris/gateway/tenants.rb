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

        # Enable an existing tenant's tenant enabled
        def enable_tenant_by_id(id, body)
          path = "#{base_uri}/tenant_enable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToEnableTenantEnabledError.new([], error))
            .to_hash
        end

        # Disable an existing tenant's tenant enabled
        def disable_tenant_by_id(id, body)
          path = "#{base_uri}/tenant_disable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToDisableTenantEnabledError.new([], error))
            .to_hash
        end

        # Enable an existing tenant's indexing enabled
        def enable_indexing_by_id(id, body)
          path = "#{base_uri}/indexing_enable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToEnableIndexingEnabledError.new([], error))
            .to_hash
        end

        # Disable an existing tenant's indexing enabled
        def disable_indexing_by_id(id, body)
          path = "#{base_uri}/indexing_disable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToDisableIndexingEnabledError.new([], error))
            .to_hash
        end

        # Enable an existing tenant's gi enabled
        def enable_gi_by_id(id, body)
          path = "#{base_uri}/gi_enable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToEnableGiEnabledError.new([], error))
            .to_hash
        end

        # Disable an existing tenant's gi enabled
        def disable_gi_by_id(id, body)
          path = "#{base_uri}/gi_disable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToDisableGiEnabledError.new([], error))
            .to_hash
        end

        # Enable an existing tenant's hf reveal enabled
        def enable_hf_reveal_by_id(id, body)
          path = "#{base_uri}/hf_reveal_enable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToEnableHfRevealEnabledError.new([], error))
            .to_hash
        end

        # Disable an existing tenant's hf reveal enabled
        def disable_hf_reveal_by_id(id, body)
          path = "#{base_uri}/hf_reveal_disable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToDisableHfRevealEnabledError.new([], error))
            .to_hash
        end

        # Enable an existing tenant's patient identity disabled
        def enable_patient_identity_by_id(id, body)
          path = "#{base_uri}/patient_identity_enable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToEnablePatientIdentityDisabledError.new([], error))
            .to_hash
        end

        # Disable an existing tenant's patient identity disabled
        def disable_patient_identity_by_id(id, body)
          path = "#{base_uri}/patient_identity_disable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToDisablePatientIdentityDisabledError.new([], error))
            .to_hash
        end

        # Enable an existing tenant's patient validation disabled
        def enable_patient_validation_by_id(id, body)
          path = "#{base_uri}/patient_validation_enable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToEnablePatientValidationDisabledError.new([], error))
            .to_hash
        end

        # Disable an existing tenant's patient validation disabled
        def disable_patient_validation_by_id(id, body)
          path = "#{base_uri}/patient_validation_disable/#{id}"
          response = request(path, { method: :post }, body)
          error = JSON.parse(response.to_s)['error']
          response
            .if_400_raise(Cdris::Gateway::Exceptions::UnableToDisablePatientValidationDisabledError.new([], error))
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
