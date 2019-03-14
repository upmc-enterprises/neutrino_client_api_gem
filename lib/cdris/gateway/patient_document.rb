require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class PatientDocument < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # Gets a test patient document
        #
        # @param [Hash] options specify query values
        # @return [Hash] the test patient document
        def test_patient_document(options = {})
          path = "#{api}/patient_document/test_document"
          request(path, options).to_hash
        end

        # Gets a patient document
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document
        def get(params, options = {})
          path = base_uri(params, options)
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                                .to_hash
        end

        # Gets a patient document's data
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [String] the patient document's data
        # @raise [Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status code
        def data(params, options = {})
          path = "#{base_uri(params)}/data"
          path += ".#{params[:format]}" if params[:format]
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                                .if_400_raise(Cdris::Gateway::Exceptions::DocumentConversionNotSupported).data_and_type
        end

        # Gets a patient document's text
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [String] the patient document's text
        def text(params, options = {})
          path = "#{base_uri(params)}/text"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentTextNotFoundError)
                                .to_s
        end

        # Highlight a document
        #
        # @param [Hash] params specify which patient document to get by id and the search term to highlight
        # @param [Hash] options specify query values
        # @return [Hash] the highlighted document in html
        # @raise [Cdris::Gateway::Exceptions::BadRequestError] when CDRIS returns a 400 status
        # @raise [Cdris::Gateway::Exceptions::InvalidTenantOperation] when CDRIS returns a 403 status
        # @raise [Cdris::Gateway::Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status
        def highlight(params, options = {})
          path = "#{api(options)}/patient_document/highlight/#{params[:id]}"
          path += ".#{params[:format]}" if params[:format]
          request(path, options.merge(literal: "#{params[:literal]}")).
            if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError).
            if_403_raise(Cdris::Gateway::Exceptions::InvalidTenantOperation).
            if_400_raise(Cdris::Gateway::Exceptions::BadRequestError).
            data_and_type
        end

        # Gets the information originally ingested for the desired patient document
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options options specify query values
        # @return [Hash] the original ingestion information
        def original_metadata(params, options = {})
          path = "#{base_uri(params)}/original_metadata"
          request(path, options).
            if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError).
            to_hash
        end

        # Gets a patient's demographics by patient document id
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [String] the patient document's data
        # @raise [Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status code
        def patient_demographics(params, options = {})
          path = "#{base_uri(params)}/patient_demographics"
          request(path, options).
            if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError).
            to_hash
        end

        # Searches for a document
        #
        # @param [Hash] options specify query values
        # @return [Hash] the patient document
        # @raise [Exceptions::BadRequestError] when CDRIS returns a 400 status code
        def search(options = {})
          path = "#{api}/patient_document/search"
          request(path, options).if_400_raise(Cdris::Gateway::Exceptions::BadRequestError)
                                .to_hash
        end

        # Searches for documents
        #
        # @param [String] search_term specify what to search for
        # @param [Hash] options specify query values
        # @return [Hash] the patient's document metadata
        # @raise [Cdris::Gateway::Exceptions::BadRequestError] when CDRIS returns a 400 status
        # @raise [Cdris::Gateway::Exceptions::InvalidTenantOperation] when CDRIS returns a 403 status
        # @raise [Cdris::Gateway::Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status
        def literal_search(search_term, options = {})
          path = "#{api}/patient_document/search"
          request(path, options.merge(literal: search_term))
              .if_400_raise(Cdris::Gateway::Exceptions::BadRequestError)
              .if_403_raise(Cdris::Gateway::Exceptions::InvalidTenantOperation)
              .if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
              .to_hash
        end

        # Gets a patient document cluster
        #
        # @param [Hash] params specify what patient to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document cluster
        def cluster(params, options = {})
          document_source_updated_at = params[:document_source_updated_at]
          document_source_updated_at_uri = document_source_updated_at.nil? ? '' : "/#{document_source_updated_at.iso8601(3)}"
          path = "#{base_uri(params)}/cluster#{document_source_updated_at_uri}"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                                .to_hash
        end

        # Gets a patient document set
        #
        # @param [Hash] params specify what patient to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document set
        def set(params, options = {})
          path = "#{base_uri(params)}/set"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                                .to_hash
        end

        def get_by_data_status_and_time_window(params, options = {})
          path = "#{api(options)}/patient_document/#{params[:data_status]}/document_creation_between/#{params[:date_from]}/#{params[:date_to]}"
          request(path, options)
              .if_400_raise(Cdris::Gateway::Exceptions::BadRequestError)
              .if_403_raise(Cdris::Gateway::Exceptions::InvalidTenantOperation)
              .to_hash
        end

        # Creates a patient document
        #
        # @param [Hash] params specify what patient to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @param [Boolean] basic_auth optional param, whether to use basic auth
        #   instead of HMAC for document creation (default: false)
        # @return [Hash] CDRIS response
        def create(body = nil, options = {}, basic_auth = false)
          path = "#{api}/patient_document"
          response = request(path, options.merge!(method: :post), body, basic_auth)
          errors = JSON.parse(response.to_s)["errors"]
          response.if_400_raise(Cdris::Gateway::Exceptions::BadRequestError.new(errors))
                  .if_401_raise(Cdris::Gateway::Exceptions::AuthenticationError.new(errors))
                  .to_hash
        end

        # Deletes a patient document
        #
        # @param [Hash] params specify what patient to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] CDRIS response
        def delete(patient_document_id, options = {})
          path = "#{api}/patient_document/delete/#{patient_document_id}"
          request(path, options.merge!(method: :delete)).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                                                        .to_hash
        end


        # Gets a list of ingestion errors
        #
        # @param [Hash] params specify which root to get `:root` (optional)
        # @param [Hash] options specify query values
        # @return [Array] the ingestion erros
        # @raise [Exceptions::BadRequestError] when CDRIS returns a 4xx status
        def ingestion_errors(params, options = {})
          path = "#{api(options)}/patient_document/ingestion_errors"
          path << "/#{params[:root]}" if params[:root]
          request(path, options)
              .if_400_raise(Cdris::Gateway::Exceptions::BadRequestError)
              .if_403_raise(Cdris::Gateway::Exceptions::InvalidTenantOperation)
              .to_hash
        end

        # Gets an ingestion error by id
        #
        # @param [Hash] params specify which id to get `:id`
        # @param [Hash] options specify query values
        # @return payload of an ingestion error
        # @raise [Exceptions::BadRequestError] when CDRIS returns a 4xx status
        def ingestion_error_by_id(params, options = {})
          path = "#{api(options)}/patient_document/ingestion_error"
          path << "/#{params[:id]}" if params[:id]
          request(path, options)
            .if_400_raise(Cdris::Gateway::Exceptions::BadRequestError)
            .if_403_raise(Cdris::Gateway::Exceptions::InvalidTenantOperation)
            .to_hash
        end

        # Gets a list of a hl7 document ids
        #
        # @param [Hash] params specify which documents to get, must specify `:root`
        # @param [Hash] options specify query values
        # @return [Array] the hl7 documents ids
        # @raise [Exceptions::BadRequestError] when CDRIS returns a 4xx status
        def hl7_document_ids(params, options = {})
          params.merge!(options)
          path = "#{api(options)}/patient_document/ids/hl7"
          request(path, params)
              .if_400_raise(Cdris::Gateway::Exceptions::BadRequestError)
              .if_403_raise(Cdris::Gateway::Exceptions::InvalidTenantOperation)
              .to_hash
        end

        # Gets a list of document ids with no patient identity expansion
        #
        # @param [Hash] params specify which document ids to get.
        # @option params [String] :patient_root Optional patient root to retrieve
        # @option params [String] :patient_extension Optional patient extension if limiting to a single MRN.
        # @option params [String] :precedence Optional request to limit ids to primanry, secondary, originator, or unknown
        # @option params [String] :date_from Optional query to limit ids for a starting created at date
        # @option params [String] :date_to Optional query to limit ids for an ending created at date
        # @param [Hash] options Other query values if needed
        # @return [Array] the documents ids
        # @raise [Exceptions::BadRequestError] when CDRIS returns a 4xx status
        def patient_document_ids(params, options = {})
          params.merge!(options)
          path = "#{api(options)}/patient_document/ids"
          path << "/#{params[:precedence]}" if params[:precedence]
          request(path, params)
              .if_400_raise(Cdris::Gateway::Exceptions::BadRequestError)
              .if_403_raise(Cdris::Gateway::Exceptions::InvalidTenantOperation)
              .to_hash
        end

        # Gets the base URI for a patient document
        #
        # @param [Hash] params specify what patient to get, must specify either `:id` or `:root` and `extension`
        # @return [String] the base URI for a patient document
        def base_uri(params, options = {})
          url = "#{api(options)}"
          url << '/patient_document'
          if params[:id].present?
            url << "/#{params[:id]}"
          elsif params[:root].present? && params[:extension].present?
            url << "/#{URI.escape(params[:root])}/#{URI.escape(params[:extension])}"
            if params[:extension_suffix].present?
              url << "/#{URI.escape(params[:extension_suffix])}"
              url << "/#{params[:document_source_updated_at].iso8601(3)}" if params[:document_source_updated_at].present?
            end
          elsif params[:root].present?
            url << "/#{URI.escape(params[:root])}"
          else
            fail Cdris::Gateway::Exceptions::BadRequestError, 'Either id or root and extension are required to create patient document path'
          end
          url
        end
      end
    end
  end
end
