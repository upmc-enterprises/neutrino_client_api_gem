require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class Nlp < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # Tests whether the NLP service is running
        #
        # @return [Boolean] true if service is running, false otherwise
        # @raise [Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status code
        def service_running?
          path = '/nlp/hf_reveal/service_test'
          request(path).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                       .code_is_not? 502
        end

        # Gets a NLP document
        #
        # @param [Hash] params specify what document to get, either `:id` or `:patient_document_id`
        # @param [Hash] options specify query values
        # @return [Hash] A NLP document
        # @raise [Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status code
        def document(params, options = {})
          path = base_uri(params, options)
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::NlpPatientDocumentNotFoundError)
                                .to_hash
        end

        # Gets a NLP document's data
        #
        # @param [Hash] params specify what document to get, either `:id` or `:patient_document_id`
        # @param [Hash] options specify query values
        # @return [String] A NLP document's data
        # @raise [Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status code
        def data(params, options = {})
          path = "#{base_uri(params, options)}/data"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::NlpPatientDocumentSourceTextNotFoundError)
                                .data_and_type
        end

        # Gets the base URI for a NLP document
        #
        # @param [Hash] params specify what document to get, either `:id` or `:patient_document_id`
        # @param [Hash] options specify query values
        # @return [String] the base URI for a NLP document
        # @raise [Exceptions::BadRequestError] when `:id` and `:patient_document_id` are not specified
        def base_uri(params, options)
          path = "#{api(options)}/nlp_patient_document"
          if params[:id]
            path << "/#{params[:id]}"
          elsif params[:patient_document_id]
            path << "/patient_document_id/#{params[:patient_document_id]}"
          else
            fail Cdris::Gateway::Exceptions::BadRequestError, 'Must provide an id or a patient_document_id'
          end
          path
        end
      end
    end
  end
end
