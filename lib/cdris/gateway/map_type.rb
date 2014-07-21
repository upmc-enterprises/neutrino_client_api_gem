require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'
require 'net/http/post/multipart'

module Cdris
  module Gateway
    class MapType < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # File formats supported for map type export
        SUPPORTED_EXPORT_FILE_TYPES = ['csv', 'xls', 'xlsx']

        # Gets a map type
        #
        # @param [Hash] params specify what map type to get, either `:unmapped`, or `:local_root` and `:local_extension`
        # @param [Hash] options specify query values
        # @return [Hash] the map type
        # @raise [Exceptions::MapTypeNotFoundError] when CDRIS returns a 404 status code
        def get(params = {}, options = {})
          path = specific_map_type_uri(params)
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::MapTypeNotFoundError)
                                .to_hash
        end

        # Gets the total number of documents remaining which require mapping
        #   updates. Warning: this call may be rather slow (~10+ seconds).
        #
        # @param [Hash] options any special options
        # @return [String] Total number of records remaining for processing.
        def get_total_document_count_to_update(options = {})
          path = "#{base_uri}/total_count_to_update"
          request(path, options).to_s
        end

        # Creates a new map type
        #
        # @param [String] map_type_body the body of the map type
        # @param [Hash] options specify query values
        # @return [Hash] the CDRIS response body
        def create_map_type(map_type_body, options = {})
          path = base_uri
          request(path, options.merge(method: :post), map_type_body).to_s
        end

        # Uploads a file containing multiple mappings.
        #
        # @param [File] mappings_file File containing map types for import
        # @param [Hash] options specify query values
        # @return [Hash] the CDRIS response body
        def import_map_type_file(uploaded_file, options = {})
          path = "#{base_uri}/import/file"
          map_type_body = map_type_import_body(uploaded_file)
          request(path, options.merge(method: :post_multipart), map_type_body, true).to_s
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
          if params[:format] && SUPPORTED_EXPORT_FILE_TYPES.include?(params[:format])
            path << ".#{params[:format]}"
          end
          path
        end

        # Gets the base URI for a map type
        #
        # @return [String] the base URI for a map type
        def base_uri
          "#{api}/map_type"
        end

        private

        # Constructs the body expected by CDRIS for multipart mapping document
        #   imports.
        #
        # @param [ActionDispatch::Http::UploadedFile] uploaded_file The file to
        #   be uploaded to CDRIS (as, for example, submitted in a web form)
        # @return [Hash] Body of the mapping import post request
        def map_type_import_body(uploaded_file)
          { 'fileUpload' => UploadIO.new(uploaded_file, uploaded_file.content_type, uploaded_file.original_filename) }
        end

      end
    end
  end
end
