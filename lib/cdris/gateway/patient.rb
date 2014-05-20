require 'cdris/gateway/requestor'
require 'cdris/gateway/uri/date_range'
require 'cdris/gateway/exceptions'
require 'cdris/gateway/uri/whitelist_factory'

module Cdris
  module Gateway
    class Patient < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # Gets a patient's demographics
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient's demographics
        # @raise [Exceptions::PatientNotFoundError] when CDRIS returns a 404 status
        def demographics(params, options = {})
          path = "#{base_uri(params)}/demographics"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientNotFoundError)
                                .to_hash
        end

        # Gets a patient's identities
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient's identities
        # @raise [Exceptions::PatientNotFoundError] when CDRIS returns a 404 status
        def identities(params, options = {})
          path = "#{base_uri(params)}/identities"
          request(path, options).if_404_raise(Cdris::Gateway::Exceptions::PatientNotFoundError)
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

        # ???
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @param [Hash] options specify query values
        # @return [Hash] the patient's ???
        # @raise [Exceptions::BadRequestError] when CDRIS returns a 400 status
        def patient_document_search(params, options = {})
          path = "#{base_uri(params)}/patient_documents/search"
          request(path, options).if_400_raise(Cdris::Gateway::Exceptions::BadRequestError)
                                .if_404_raise(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
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
          request(path, options).to_hash
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
            .if_404_raise(Cdris::Gateway::Exceptions::PatientNotFoundError)
            .to_hash
        end

        # Gets the base URI for a patient
        #
        # @param [Hash] params specify what patient to get, must specify `:root` and `extension`
        # @return [String] the base URI for a patient
        # @raise [Exceptions::BadRequestError] when `:root` or `:extension` are not specified
        def base_uri(params)
          if params[:root].nil? || params[:extension].nil?
            fail Cdris::Gateway::Exceptions::BadRequestError, 'Must specify a root and extension'
          end

          "#{api}/patient/#{params[:root]}/#{params[:extension]}"
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
