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
                                .data_and_type
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

        # Gets a patient document's facts
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's facts
        def facts(params, options = {})
          path = "#{base_uri(params)}/facts"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
                                .to_hash
        end

        # Gets a patient document's ICD9 problem codes (and code information)
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's ICD9 problem codes
        def icd9_problem_codes(params, options = {})
          path = "#{base_uri(params)}/facts/problems/icd9/all"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
                                .to_hash
        end

        # Gets a patient document's ICD10 problem codes (and code information)
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's ICD10 problem codes
        def icd10_problem_codes(params, options = {})
          path = "#{base_uri(params)}/facts/problems/icd10/all"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
                                .to_hash
        end

        # Gets a patient document's ICD9 codes (codes only)
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's ICD9 codes
        def icd9_problem_codes_simple(params, options = {})
          path = "#{base_uri(params)}/facts/icd9"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
                                .to_hash
        end

        # Gets a patient document's SNOMED problem codes
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's SNOMED problem codes
        def snomed_problem_codes(params, options = {})
          path = "#{base_uri(params)}/facts/problems/snomed/all"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
                                .to_hash
        end

        # Gets a patient document's SNOMED vitals
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's SNOMED vital information
        def snomed_vitals(params, options = {})
          path = "#{base_uri(params)}/facts/vitals/snomed/all"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
                                .to_hash
        end

        # Gets a patient document's clinical, SNOMED problem codes
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's clinical, SNOMED problem codes
        def snomed_problem_codes_clinical(params, options = {})
          path = "#{base_uri(params)}/facts/problems/snomed/clinical"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
                                .to_hash
        end

        # Gets a patient document's SNOMED procedure codes
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's SNOMED procedure codes
        def snomed_procedure_codes(params, options = {})
          path = "#{base_uri(params)}/facts/procedures/snomed/all"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
                                .to_hash
        end

        def procedures(params, options = {})
          path = "#{base_uri(params)}/facts/procedures"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
                                .to_hash
        end

        # Gets a patient document's ejection fractions
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's ejection fractions
        def ejection_fractions(params, options = {})
          if params[:id]
            path = "#{base_uri(params)}/facts/ejection_fraction"
          else
            path = "#{api}/patient/#{params[:root]}/#{params[:extension]}/patient_documents/current/with/ejection_fractions"
          end
          request(path, options).to_hash
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
          response.if_400_raise(Cdris::Gateway::Exceptions::BadRequestError.new(errors)).to_hash
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
            url << "/#{params[:root]}/#{params[:extension]}"
            if params[:extension_suffix].present?
              url << "/#{params[:extension_suffix]}"
              url << "/#{params[:document_source_updated_at].iso8601(3)}" if params[:document_source_updated_at].present?
            end
          else
            fail Cdris::Gateway::Exceptions::BadRequestError, 'Either id or root and extension are required to create patient document path'
          end
          url
        end
      end
    end
  end
end
