require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class Clu < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # Tests whether the CLU service is running
        #
        # @return [Boolean] true if service is running, false otherwise
        # @raise [Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status code
        def service_running?
          path = '/nlp/clu/service_test'
          request(path).if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
                       .code_is_not? 502
        end

        # Gets a CLU document
        #
        # @param [Hash] params specify what document to get, either `:id` or `:patient_document_id`
        # @param [Hash] options specify query values
        # @return [Hash] A CLU document
        # @raise [Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status code
        def document(params, options = {})
          path = base_uri(params, options)
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::CluPatientDocumentNotFoundError)
                                .to_hash
        end

        # Gets a CLU document's data
        #
        # @param [Hash] params specify what document to get, either `:id` or `:patient_document_id`
        # @param [Hash] options specify query values
        # @return [String] A CLU document's data
        # @raise [Exceptions::PatientDocumentNotFoundError] when CDRIS returns a 404 status code
        def data(params, options = {})
          path = "#{base_uri(params, options)}/data"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::CluPatientDocumentSourceTextNotFoundError)
                                .data_and_type
        end

        # Gets the base URI for a CLU document
        #
        # @param [Hash] params specify what document to get, either `:id` or `:patient_document_id`
        # @param [Hash] options specify query values
        # @return [String] the base URI for a CLU document
        # @raise [Exceptions::BadRequestError] when `:id` and `:patient_document_id` are not specified
        def base_uri(params, options)
          path = "#{api(options)}/clu_patient_document"
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
