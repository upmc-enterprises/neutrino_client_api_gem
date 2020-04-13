require 'neutrino/gateway/requestor'
require 'neutrino/gateway/uri/date_range'
require 'neutrino/gateway/exceptions'
require 'neutrino/gateway/uri/whitelist_factory'

module Neutrino
  module Gateway
    class Patient < Neutrino::Gateway::Requestor
      private_class_method :new
      class << self

        # Override for patient class request
        # This raises a PatientIdentityGatewayNotAuthorizedError error if
        # repo returns a 403
        #
        # @param [Array] args is a splat of arguements
        # @return [Responses::ResponseHandler] a `ResponseHandler` instance for handling response codes
        # @raise [Neutrino::Gateway::Exceptions::PatientIdentityGatewayNotAuthorizedError] when repo returns a 403
        def request(*args)
          super(*args)
            .with_general_exception_check('403', /authorized.*patient.*identity|patient.*identity.*authorized/i,
                                          Neutrino::Gateway::Exceptions::PatientIdentityGatewayNotAuthorizedError)
        end

        # Gets a patient's demographics
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient's demographics
        # @raise [Exceptions::PatientNotFoundError] when NEUTRINO returns a 404 status
        def demographics(params, options = {})
          path = "#{base_uri(params)}/demographics"
          request(path, options).if_404_raise(Neutrino::Gateway::Exceptions::PatientNotFoundError)
                                .to_hash
        end

        # Gets a patient's identities
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient's identities
        # @raise [Exceptions::PatientNotFoundError] when NEUTRINO returns a 404 status
        def identities(params, options = {})
          path = "#{base_uri(params)}/identities"
          request(path, options)
              .with_patient_identity_set_in_error_check
              .if_404_raise(Neutrino::Gateway::Exceptions::PatientNotFoundError)
              .to_hash
        end

        # Gets patient identities that are in error
        #
        # @param [Hash] options specify query values
        # @return [Array] array of hashes of identities in error
        # @raise [Exceptions::InvalidTenantOperation] when NEUTRINO returns a 403 status
        def identities_in_error(options = {})
          path = "#{api}/patient/identities_in_error"
          request(path, options)
            .if_403_raise(Neutrino::Gateway::Exceptions::InvalidTenantOperation).to_hash
        end

        # Sets a patient's identities in error
        #
        # @param [Hash] params specify what patient to set into error, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [boolean] true if patient's identities were not already in error, false if they were
        # @raise [Exceptions::PatientNotFoundError] when NEUTRINO returns a 404 status
        def set_in_error(params, options = {})
          path = "#{base_uri(params)}/set_in_error"
          request(path, options.merge(method: :post), {})
            .if_404_raise(Neutrino::Gateway::Exceptions::PatientNotFoundError).to_hash['data_status']
        end

        # Invoke self-healing on all members of a patient identity set
        #
        # @param [Hash] params specify what patient to invoke self healing on, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [boolean] true if patient self healing was successful, false if not
        # @raise [Exceptions::InvalidTenantOperation] when NEUTRINO returns a 403 status
        # @raise [Exceptions::PatientNotFoundError] when NEUTRINO returns a 404 status
        def self_healing(params, options = {})
          path = "#{base_uri(params)}/self_healing"
          request(path, options.merge(method: :post), {})
            .if_404_raise(Neutrino::Gateway::Exceptions::PatientNotFoundError)
            .if_403_raise(Neutrino::Gateway::Exceptions::InvalidTenantOperation)
            .to_hash['message']
        end

        # Gets a patient's active identities
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient's identities
        # @raise [Exceptions::PatientNotFoundError] when NEUTRINO returns a 404 status
        def active_identities(params, options = {})
          path = "#{base_uri(params)}/active_identities"
          request(path, options)
              .with_patient_identity_set_in_error_check
              .if_404_raise(Neutrino::Gateway::Exceptions::PatientNotFoundError)
              .to_hash
        end

        # Whether a patient is valid
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] `true` if patient is valid
        def valid?(params, options = {})
          path = "#{base_uri(params)}/validate"
          request(path, options).to_hash['valid']
        end

        # Deletes a patient identity
        #
        # @param [Hash] params specifies which patient to get, must specify `:root` and `:extension`
        # @param [Hash] options specifies query values
        # @return [Hash] data about the patient that was deleted
        def delete(params, options={})
          request("#{base_uri(params)}/delete", options.merge(method: :delete))
          .if_403_raise(Neutrino::Gateway::Exceptions::InvalidTenantOperation)
          .if_404_raise(Neutrino::Gateway::Exceptions::PatientNotFoundError)
          .with_general_exception_check('409', /has documents/, Neutrino::Gateway::Exceptions::PatientIdentityHasDocumentsError)
          .with_general_exception_check('409', /is not in Error/, Neutrino::Gateway::Exceptions::PatientIdentityNotInError)
          .to_hash['data_status']
        end

        # ???
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient's ???
        # @raise [Exceptions::BadRequestError] when NEUTRINO returns a 400 status
        def patient_document_search(params, options = {})
          path = "#{base_uri(params)}/patient_documents/search"
          request(path, options)
              .if_400_raise(Neutrino::Gateway::Exceptions::BadRequestError)
              .if_403_raise(Neutrino::Gateway::Exceptions::InvalidTenantOperation)
              .if_404_raise(Neutrino::Gateway::Exceptions::PatientDocumentNotFoundError)
              .to_hash
        end

        # Gets a list of a patient's hl7 document ids
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Array] the patient's hl7 documents ids
        # @raise [Exceptions::BadRequestError] when NEUTRINO returns a 400 status
        def patient_hl7_document_ids(params, options = {})
          path = "#{base_uri(params)}/ids/hl7"
          request(path, options)
              .if_400_raise(Neutrino::Gateway::Exceptions::BadRequestError)
              .if_403_raise(Neutrino::Gateway::Exceptions::InvalidTenantOperation)
              .to_hash
        end

        # Gets a list of a patient's document ids
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `:extension`
        # @param [Hash] options specify query values
        # @return [Array] the patient's documents ids
        # @raise [Exceptions::BadRequestError] when NEUTRINO returns a 400 status
        def patient_document_ids(params, options = {})
          path = "#{base_uri(params)}/ids"
          path << "/#{params[:precedence]}" if params[:precedence]
          request(path, options)
              .if_400_raise(Neutrino::Gateway::Exceptions::BadRequestError)
              .if_403_raise(Neutrino::Gateway::Exceptions::InvalidTenantOperation)
              .to_hash
        end

        # Gets a patient's document's bounds
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient's document's bounds
        def patient_document_bounds(params, options = {})
          path = "#{base_uri(params)}/patient_document_bounds"
          path << current_if_specified_in(params)
          request(path, options)
              .if_403_raise(Neutrino::Gateway::Exceptions::InvalidTenantOperation)
              .to_hash
        end

        # Gets a patient's subject matter domains
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient's subject matter domains
        def subject_matter_domains(params, options = {})
          path = "#{base_uri(params)}/patient_documents"
          path << current_if_specified_in(params)
          path << '/subject_matter_domain_extension'
          request(path, options).to_hash
        end

        # Gets the types of service that pertain to a patient
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient's types of service
        def types_of_service(params, options = {})
          path = "#{base_uri(params)}/patient_documents"
          path << current_if_specified_in(params)
          path << '/type_of_service_extension'
          request(path, options).to_hash
        end

        # Gets a patient's documents
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        #   can specify `:date_from` and `:date_to` to filter a range, and/or various whitelists
        # @param [Hash] options specify query values
        # @return [Hash] the patient's documents
        def patient_documents(params, options = {})
          path = "#{base_uri(params)}/patient_documents"

          path << Uri::DateRange.new
                    .beginning_at(params[:date_from])
                    .ending_at(params[:date_to])
                    .to_s

          path << Uri::WhitelistFactory.new
                    .from_whitelists_in(params)
                    .build
                    .to_s

          path << current_if_specified_in(params)

          request(path, options)
            .if_403_raise(Neutrino::Gateway::Exceptions::InvalidTenantOperation)
            .if_404_raise(Neutrino::Gateway::Exceptions::PatientNotFoundError)
            .to_hash
        end

        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`,
        #
        # @param [Hash] options specify query values
        #                      specify what literal to search
        # @return [Hash] the patient's documents ids
        # @raise [Exceptions::BadRequestError] when NEUTRINO returns a 400 status
        def patient_documents_literal_search(params, options = {})
          path = "#{base_uri(params)}/patient_documents/search"
          request(path, options)
              .if_400_raise(Neutrino::Gateway::Exceptions::BadRequestError)
              .if_403_raise(Neutrino::Gateway::Exceptions::InvalidTenantOperation)
              .if_404_raise(Neutrino::Gateway::Exceptions::PatientDocumentNotFoundError)
              .to_hash
        end

        # Gets the base URI for a patient
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @return [String] the base URI for a patient
        # @raise [Exceptions::BadRequestError] when `:root` or `:extension` are not specified
        def base_uri(params)
          if params[:root].nil? || params[:extension].nil?
            fail Neutrino::Gateway::Exceptions::BadRequestError, 'Must specify a root and extension'
          end

          "#{api}/patient/#{URI.escape(params[:root])}/#{URI.escape(params[:extension])}"
        end

        # Gets a URI component indicating current if `:current` in `params`, else gets an empty string
        #
        # @param [Hash] params where to look for `:currrent`
        # @return [String] the current URI component or and empty string
        def current_if_specified_in(params)
          params[:current] ? '/current' : ''
        end
      end
    end
  end
end
