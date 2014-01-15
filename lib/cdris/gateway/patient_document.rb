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
        def test_patient_document(options={})
          path = "#{api}/patient_document/test_document"
          request(path, options).to_hash
        end

        # Gets a patient document
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document
        def get(params, options={})
          path = base_uri(params.merge({debug: true}))
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                                .to_hash
        end

        # Gets a patient document's data
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [String] the patient document's data
        # @raise [Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status code
        def data(params, options={})
          path = "#{base_uri(params)}/data"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                                .data_and_type
        end

        # Gets a patient document's text
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [String] the patient document's text
        def text(params, options={})
          path = "#{base_uri(params)}/text"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentTextNotFoundError)
                                .to_s
        end

        # Gets a patient document's facts
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's facts
        def facts(params, options={})
          path = "#{base_uri(params)}/facts"
          request(path, options).to_hash
        end

        # Gets a patient document's ICD9 problem codes (and code information)
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's ICD9 problem codes
        def icd9_problem_codes(params, options={})
          path = "#{base_uri(params)}/facts/problems/icd9/all"
          request(path, options).to_hash
        end

        # Gets a patient document's ICD9 codes (codes only)
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's ICD9 codes
        def icd9_problem_codes_simple(params, options={})
          path = "#{base_uri(params)}/facts/icd9"
          request(path, options).to_hash
        end

        def # Gets a patient document's SNOMED problem codes
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's SNOMED problem codes
        snomed_problem_codes(params, options={})
          path = "#{base_uri(params)}/facts/problems/snomed/all"
          request(path, options).to_hash
        end

        # Gets a patient document's clinical, SNOMED problem codes
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's clinical, SNOMED problem codes
        def snomed_problem_codes_clinical(params, options={})
          path = "#{base_uri(params)}/facts/problems/snomed/clinical"
          request(path, options).to_hash
        end

        # Gets a patient document's SNOMED procedure codes
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's SNOMED procedure codes
        def snomed_procedure_codes(params, options={})
          path = "#{base_uri(params)}/facts/procedures/snomed/all"
          request(path, options).to_hash
        end

        # Gets a patient document's ejection fractions
        #
        # @param [Hash] params specify what patient document to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document's ejection fractions
        def ejection_fractions(params, options={})
          path = "#{api}/patient/#{params[:root]}/#{params[:extension]}/patient_documents/current/with/ejection_fractions"
          request(path, options).to_hash
        end

        # Searches for a document
        #
        # @param [Hash] options specify query values
        # @return [Hash] the patient document
        # @raise [Exceptions::BadRequestError] when CDRIS returns a 400 status code
        def search(options={})
          path = "#{api}/patient_document/search"
          request(path, options).if_400_raise(Cdris::Gateway::Exceptions::BadRequestError)
                                .to_hash
        end

        # Gets a patient document cluster
        #
        # @param [Hash] params specify what patient to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document cluster
        def cluster(params, options={})
          document_source_updated_at = params[:document_source_updated_at]
          document_source_updated_at_uri = document_source_updated_at.nil? ? "" : "/#{document_source_updated_at}" 
          path = "#{base_uri(params)}/cluster#{document_source_updated_at_uri}"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                                .to_hash
        end

        # Gets a patient document set
        #
        # @param [Hash] params specify what patient to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient document set
        def set(params, options={})
          path = "#{base_uri(params)}/set"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                                .to_hash
        end

        # Creates a patient document
        #
        # @param [Hash] params specify what patient to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] CDRIS response
        def create(body=nil, options={})
          path = "#{api}/patient_document"
          request(path, options.merge!({method: :post}), body).to_hash
        end

        # Deletes a patient document
        #
        # @param [Hash] params specify what patient to get, must specify either `:id` or `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] CDRIS response
        def delete(patient_document_id, options={})
          path = "#{api}/patient_document/delete/#{patient_document_id}"
          request(path, options.merge!({method: :delete})).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                                                          .to_hash
        end

        # Gets the base URI for a patient document
        #
        # @param [Hash] params specify what patient to get, must specify either `:id` or `:root` and `extension`
        # @return [String] the base URI for a patient document
        def base_uri(params)
          url = "#{api}"
          url << '/debug/true' if params[:debug]
          url << '/patient_document'
          if params[:id]
            url << "/#{params[:id]}"
          elsif params[:root] && params[:extension]
            url << "/#{params[:root]}/#{params[:extension]}"
            if params[:extension_suffix]
              url << "/#{params[:extension_suffix]}" 
              url << "/#{params[:document_source_updated_at]}" if params[:document_source_updated_at]
            end
          else
            raise Cdris::Gateway::Exceptions::BadRequestError, 'Either id or root and extension are required to create patient document path'
          end
          url
        end
      end
    end
  end
end
