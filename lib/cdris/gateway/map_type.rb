require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class MapType < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # Gets a map type
        #
        # @param [Hash] params specify what map type to get, either `:unmapped`, or `:local_root` and `:local_extension`
        # @param [Hash] options specify query values
        # @return [Hash] the map type
        # @raise [Exceptions::MapTypeNotFoundError] when CDRIS returns a 404 status code
        def get(params={}, options={})
          path = specific_map_type_uri(params)
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::MapTypeNotFoundError)
                                .to_hash
        end

        # Creates a new map type
        #
        # @param [String] map_type_body the body of the map type
        # @param [Hash] options specify query values
        # @return [Hash] the CDRIS response body
        def create_map_type(map_type_body, options={})
          path = base_uri
          request(path, options.merge({method: :post}), map_type_body).to_s
        end

        # Gets the URI for a specific map type
        #
        # @param [Hash] params specify what map type to get, either `:unmapped`, or `:local_root` and `:local_extension`
        # @return [String] the base URI for getting a specific map type as specified by `params`
        # @raise [Exceptions::BadRequestError] when `:unmapped` is not specified or `:local_root` and `:local_extension` are not specified
        def specific_map_type_uri(params)
          path = base_uri
          path << "/#{params[:type]}" if params[:type]
          path << '/unmapped' if params[:unmapped]
          path
        end

        # Gets the base URI for a map type
        #
        # @return [String] the base URI for a map type
        def base_uri
          "#{api}/map_type"
        end
      end
    end
  end
end
