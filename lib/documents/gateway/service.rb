require 'documents/gateway/requestor'
require 'documents/gateway/exceptions'

module Neutrino
  module Gateway
    class Service < Neutrino::Gateway::Requestor
      private_class_method :new
      class << self

        # Gets derived works data
        #
        # @param [Hash] params specify what document to get, either `:id` or `:patient_document_id`
        # Additionally need both ':service_class' and ':service_identifier'
        # @param [Hash] options specify query values.
        # @return [Hash] Derived works data
        # @raise [Exceptions::PatientDocumentNotFoundError] when NEUTRINO returns a 404 status code
        def data(params, options = {})
          path = "#{base_uri(params, options)}/data"
          request(path, options).if_404_raise(Neutrino::Gateway::Exceptions::DerivedWorkDocumentNotFoundError)
              .data_and_type
        end

        # Gets derived works metadata
        #
        # @param [Hash] params specify what document to get, either `:id` or `:patient_document_id`
        # Additionally need both ':service_class' and ':service_identifier'
        # @param [Hash] options specify query values.
        # @return [Hash] Derived works data
        # @raise [Exceptions::PatientDocumentNotFoundError] when NEUTRINO returns a 404 status code
        def metadata(params, options = {})
          path = "#{base_uri(params, options)}"
          request(path, options).if_404_raise(Neutrino::Gateway::Exceptions::DerivedWorkDocumentNotFoundError)
              .to_hash
        end

        # Gets the base URI for NLP GI data
        #
        # @param [Hash] params specify what document to get, either `:id`, `:patient_document_id`
        # Additionally need both ':service_class' and ':service_identifier'
        # @param [Hash] options specify query values.
        # @return [String] the base URI for derived works data
        # @raise [Exceptions::BadRequestError] when `:id` and `:patient_document_id` are not specified
        def base_uri(params, options)
          path = "#{api(options)}"
          if params[:service_class] && params[:service_identifier]
            if params[:id]
              path << "/patient_document/#{params[:id]}/service/#{params[:service_class]}/#{params[:service_identifier]}"
            elsif params[:patient_document_id]
              path << "/patient_document/#{params[:patient_document_id]}/service/#{params[:service_class]}/#{params[:service_identifier]}"
            else
              fail Neutrino::Gateway::Exceptions::BadRequestError, 'Must provide an id or a patient_document_id'
            end
          else
            fail Neutrino::Gateway::Exceptions::BadRequestError, 'Must provide an service_class and service_identifier'
          end
          path
        end

      end
    end
  end
end
