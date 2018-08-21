require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class Provider < Cdris::Gateway::Requestor
      private_class_method :new
      class << self
        # Creates a new provider
        #
        # @param [Hash] provider_body the body of the provider
        # @param [Hash] options specify query values
        # @return [Hash] the CDRIS response body
        def create(provider_body, options = {})
          path = base_uri
          request(path, options.merge(method: :post), provider_body).if_400_raise(Cdris::Gateway::Exceptions::ProviderInvalidError).to_hash
        end

        # Shows all providers
        #
        # @param [Hash] params
        # @param [Hash] options specify query values
        # @return [Array] the providers
        def show_providers(params, options = {})
          path = base_uri
          request(path, options).to_json
        end

        # Gets a provider
        #
        # @param [Hash] params specify which provider to get, must specify `:id`
        # @param [Hash] options specify query values
        # @return [Hash] the provider
        def get(params, options = {})
          path = "#{base_uri}/#{params[:id]}"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::ProviderNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::ProviderInvalidError)
            .to_hash
        end

        # Update a provider
        #
        # @param [Hash] params specify which provider to update, must specify `:id`
        # @param [Hash] options specify query values
        # @return [Hash] the provider
        def update_by_id(params, options = {})
          path = "#{base_uri}/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Cdris::Gateway::Exceptions::ProviderNotFoundError)
            .if_400_raise(Cdris::Gateway::Exceptions::ProviderInvalidError)
            .to_hash
        end

        # Delete a provider
        #
        # @param [Hash] params specify which provider to delete, must specify `:id`
        # @param [Hash] options specify query values
        # @return [Hash] the provider
        def delete_by_id(params, options = {})
          path = "#{base_uri}/#{params[:id]}"
          request(path, options.merge(method: :delete)).if_404_raise(Cdris::Gateway::Exceptions::ProviderNotFoundError)
        end

        # Gets the base URI for a provider
        #
        # @return [String] the base URI for a provider
        def base_uri
          "#{api}/provider"
        end
      end
    end
  end
end
