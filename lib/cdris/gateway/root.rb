require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class Root < Cdris::Gateway::Requestor
      private_class_method :new
      class << self
        # Creates a new root
        #
        # @param [Hash] root_body the body of the root
        # @param [Hash] options specify query values
        # @return [Hash] the CDRIS response body
        def create(root_body, options = {})
          path = base_uri
          request(path, options.merge(method: :post), root_body).if_400_raise(Cdris::Gateway::Exceptions::RootInvalidError)
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
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::RootNotFoundError)
                                .if_400_raise(Cdris::Gateway::Exceptions::RootInvalidError)
                                .to_hash
        end

        # Update a root
        #
        # @param [Hash] params specify what root to update, must specify `:id`
        # @param [Hash] options specify query values
        # @return [Hash] the root
        def update_by_id(params, options = {})
          path = "#{base_uri}/#{params[:id]}"
          request(path, options.merge(method: :post), params).if_404_raise(Cdris::Gateway::Exceptions::RootNotFoundError)
                                .if_400_raise(Cdris::Gateway::Exceptions::RootInvalidError)
                                .to_hash
        end

        # Delete a root
        #
        # @param [Hash] params specify what root to delete, must specify `:id`
        # @param [Hash] options specify query values
        # @return [Hash] the root
        def delete_by_id(params, options = {})
          path = "#{base_uri}/#{params[:id]}"
          request(path, options.merge(method: :delete)).if_404_raise(Cdris::Gateway::Exceptions::RootNotFoundError)
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
