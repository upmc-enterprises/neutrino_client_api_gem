require 'cdris/api/client'
require 'cdris/gateway/whitelisting/whitelist_factory'
require 'cdris/helpers/date_range'
require 'exceptions.rb'

module Cdris
  module Gateway
    module Routes
      class Base
        include Exceptions

        # Gets the base URI for the API
        #
        # @return [String] the base URI for the API
        def self.api
          "/api/v#{Cdris::Api::Client.api_version}"
        end

        # Builds and gets the base URI for a PatientDocument
        #
        # @param [Hash] params the values from which to build a patient's document URI
        # @return [String] the base URI for a PatientDocument
        # @raise [Exceptions::BadRequestError] if document id, or root and extension are not given params
        def self.patient_document(params)
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
            raise Exceptions::BadRequestError, 'Either id or root and extension are required to create patient document path'
          end
          url
        end

        # Gets the base URI for a Patient
        #
        # @param [Hash] params the values from which to build a patient's URI
        # @return [String] the base URI for a Patient
        # @raise [Exceptions::BadRequestError] if root and extension are not specified
        def self.patient(params)
          if params[:root].nil? || params[:extension].nil?
            raise Exceptions::BadRequestError, 'Must specify a root and extension' 
          end

          "#{api}/patient/#{params[:root]}/#{params[:extension]}"
        end

        # Gets the base URI for a NamedQuery
        #
        # @return [String] the base URI for a NamedQuery
        def self.named_query
          "#{api}/named_query"
        end

        # Gets the base URI for Info
        #
        # @return [String] the base URI for Info
        def self.info
          "/cdris"
        end

        # Gets the base URI for MapType
        #
        # @return [String] the base URI for MapType
        def self.map_type
          "#{api}/map_type"
        end

        # Builds and gets the base URI for Clu
        #
        # @return [String] the base URI for Clu
        # @raise [Exceptions::BadRequestError] if an id or patient_document_id are not given
        def self.clu(params, options)
          path = "#{Routes::Base.api}/clu_patient_document"
          path << '/debug/true' if options[:debug]
          if params[:id]
            path << "/#{params[:id]}"
          elsif params[:patient_document_id]
            path << "/patient_document_id/#{params[:patient_document_id]}"
          else
            raise Exceptions::BadRequestError, 'Must provide an id or a patient_document_id'
          end
          path
        end
      end

      class NamedQuery
        
        # Gets the URI for a NamedQuery with a certain name
        #
        # @param [Object] name the name of the query to get
        # @return [String] the URI for a NamedQuery with a certain name
        def self.with_name(name)
          "#{Base.named_query}/#{name}"
        end

      end

      class Info
      
        def self.deployments
          "#{Base.info}/deployments"
        end

        def self.current_deployment
          "#{Base.info}/deployment/current"
        end

        def self.configuration(category=nil)
          "#{Base.info}/configuration#{category ? '/'+category : ''}"
        end

      end

      class PatientDocument
        
        def self.test_patient_document
          "#{Base.api}/patient_document/test_document"
        end

        def self.data(params)
          "#{Base.patient_document(params)}/data"
        end

        def self.text(params)
          "#{Base.patient_document(params)}/text"
        end

        def self.facts(params)
          "#{Base.patient_document(params)}/facts"
        end

        def self.icd9_problem_codes(params)
          "#{Routes::Base.patient_document(params)}/facts/problems/icd9/all"
        end

        def self.icd9_problem_codes_simple(params)
          "#{Routes::Base.patient_document(params)}/facts/icd9"
        end

        def self.snomed_problem_codes(params)
          "#{Routes::Base.patient_document(params)}/facts/problems/snomed/all"
        end

        def self.snomed_problem_codes_clinical(params)
          "#{Routes::Base.patient_document(params)}/facts/problems/snomed/clinical"
        end

        def self.snomed_procedure_codes(params)
          "#{Routes::Base.patient_document(params)}/facts/procedures/snomed/all"
        end

        def self.ejection_fractions(params)
          "#{Routes::Base.patient_document(params)}/facts/ejection_fraction"
        end

        def self.search
          "#{Base.api}/patient_document/search"
        end

        def self.cluster(params)
          document_source_updated_at = params[:document_source_updated_at]
          document_source_updated_at_uri = document_source_updated_at.nil? ? "" : "/#{document_source_updated_at}" 
          "#{Base.patient_document(params)}/cluster#{document_source_updated_at_uri}"
        end

        def self.set(params)
          "#{Base.patient_document(params)}/set"
        end

        def self.delete(patient_document_id)
          "#{Routes::Base.api}/patient_document/delete/#{patient_document_id}"
        end

      end

      class Clu

        def self.service_test
          '/nlp/clu/service_test'
        end

        def self.data(params, options)
          "#{Base.clu(params, options)}/data"
        end

      end

      class MapType

        def self.get(params)
          path = Base.map_type
          path << "#{params[:type]}" if params[:type]
          if params[:unmapped] && params[:local_root].nil? && params[:local_extension].nil?
            path << '/unmapped'
          elsif (params[:local_root] && params[:local_extension]) && params[:unmapped].nil?
            path << "/#{params[:local_root]}/#{params[:local_extension]}"
          else
            raise Exceptions::BadRequestError, 'Must specify either unmapped, or local_root and local_extension'
          end
          path
        end

      end

      class Patient

        def self.demographics(params)
          "#{Base.patient(params)}/demographics"
        end

        def self.identities(params)
          "#{Base.patient(params)}/identities"
        end

        def self.validate(params)
          "#{Base.patient(params)}/validate"
        end

        def self.document_search(params)
          "#{Base.patient(params)}/patient_documents/search"
        end

        def self.document_bounds(params)
          path = "#{Base.patient(params)}/patient_document_bounds"
          path << current_if_specified_in(params)
          path
        end

        def self.subject_matter_domain(params)
          path = "#{Base.patient(params)}/patient_documents"
          path << current_if_specified_in(params)
          path << '/subject_matter_domain_extension'
          path
        end

        def self.types_of_service(params)
          path = "#{Routes::Base.patient(params)}/patient_documents"
          path << current_if_specified_in(params)
          path << '/type_of_service_extension'
          path
        end

        def self.patient_documents(params)
          path = "#{Routes::Base.patient(params)}/patient_documents"

          path << DateRange.new
                    .beginning_at(params[:date_from])
                    .ending_at(params[:date_to])
                    .to_uri

          path << Cdris::Gateway::Whitelisting::WhitelistUriFactory.new
                    .from_whitelists_in(params)
                    .build
                    .to_s

          path << current_if_specified_in(params)
          path  
        end

        def self.current_if_specified_in(params)
          params[:current] ? '/current' : ''
        end
        
        private_class_method :current_if_specified_in
      end
    end
  end
end
