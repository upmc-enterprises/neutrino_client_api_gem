require 'neutrino/gateway/requestor'
require 'neutrino/gateway/exceptions'

module Neutrino
  module Gateway
    class Root < Neutrino::Gateway::Requestor
      private_class_method :new
      class << self
        # Creates a new root
        #
        # @param [Hash] root_body the body of the root
        # @param [Hash] options specify query values
        # @return [Hash] the NEUTRINO response body
        def create(root_body, options = {})
          path = base_uri
          request(path, options.merge(method: :post), root_body)
            .with_general_exception_check('400', /Create or update a root with a non-existent provider/, Neutrino::Gateway::Exceptions::PostRootWithNonExistProviderError)
            .if_400_raise(Neutrino::Gateway::Exceptions::RootInvalidError)
            .to_hash
        end

        # Show all roots
        #
        # @param [Hash] params
        # @param [Hash] options specify query values
        # @return [Hash] the root
        def show_roots(params, options = {})
          path = base_uri
          request(path, options).to_json
        end

        # Gets a root
        #
        # @param [Hash] params specify what root to get, must specify `:id`
        # @param [Hash] options specify query values
        # @return [Hash] the root
        def get(params, options = {})
          path = "#{base_uri}/#{params[:id]}"
          request(path, options).if_404_raise(Neutrino::Gateway::Exceptions::RootNotFoundError)
                                .if_400_raise(Neutrino::Gateway::Exceptions::RootInvalidError)
                                .to_hash
        end

        # Update a root
        #
        # @param [Hash] params specify what root to update, must specify `:id`
        # @param [Hash] options specify query values
        # @return [Hash] the root
        def update_by_id(params, options = {})
          path = "#{base_uri}/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Neutrino::Gateway::Exceptions::RootNotFoundError)
            .with_general_exception_check('400', /Create or update a root with a non-existent provider/, Neutrino::Gateway::Exceptions::PostRootWithNonExistProviderError)
            .if_400_raise(Neutrino::Gateway::Exceptions::RootInvalidError)
            .to_hash
        end

        # Delete a root
        #
        # @param [Hash] params specify what root to delete, must specify `:id`
        # @param [Hash] options specify query values
        # @return [Hash] the root
        def delete_by_id(params, options = {})
          path = "#{base_uri}/#{params[:id]}"
          request(path, options.merge(method: :delete)).if_404_raise(Neutrino::Gateway::Exceptions::RootNotFoundError)
            .if_409_raise(Neutrino::Gateway::Exceptions::DeleteRootWithProviderError)
        end

        # Gets the base URI for a root
        #
        # @return [String] the base URI for a root
        def base_uri
          "#{api}/root"
        end
      end
    end
  end
end
