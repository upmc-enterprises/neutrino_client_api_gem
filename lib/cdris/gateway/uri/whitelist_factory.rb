require 'cdris/gateway/exceptions'
require 'cdris/gateway/uri/whitelist'

module Cdris
  module Gateway
    module Uri
      class WhitelistFactory

        # Sets the hash within which to find whitelisting information used to build `Whitelist`s
        #
        # @param [Hash] whitelist_hash specifies whitelisting information
        # @return [WhitelistFactory] `self`, for method chaining
        def from_whitelists_in(whitelist_hash)
          @whitelist_hash = whitelist_hash
          @specified_whitelists = whitelist_hash.keys & self.class.known_whitelists
          self
        end

        # Builds a Whitelist, making decisions from values specified in the whitelist Hash
        #
        # @return [Whitelist] the constructed Whitelist
        def build
          fail Cdris::Gateway::Exceptions::BadRequestError if @specified_whitelists.count > 1
          whitelist = @specified_whitelists.first
          values = @whitelist_hash[whitelist]

          case whitelist

          when :type_of_service_whitelist
            Whitelist.new
                     .with_template('/type_of_service_list/{value}')
                     .and_values(values)
                     .error_on_empty(Cdris::Gateway::Exceptions::TypesOfServiceNotProvided)

          when :subject_matter_domain_whitelist
            Whitelist.new
                     .with_template('/subject_matter_domain_list/{value}')
                     .and_values(values)
                     .error_on_empty(Cdris::Gateway::Exceptions::SubjectMatterDomainsNotProvided)

          when :with_ejection_fractions
            Whitelist.new.with_template('/with/ejection_fractions')

          when :snomed_problem_whitelist
            Whitelist.new
                     .with_template('/problem_whitelist/snomed/{value}')
                     .and_values(values)
                     .append_component(clinical_or_all)
                     .error_on_empty(Cdris::Gateway::Exceptions::SnomedCodesNotProvided)

          when :snomed_procedure_whitelist
            Whitelist.new
                     .with_template('/procedure_whitelist/snomed/{value}/all')
                     .and_values(values)
                     .error_on_empty(Cdris::Gateway::Exceptions::SnomedCodesNotProvided)

          when :snomed_vital_whitelist
            Whitelist.new
                     .with_template('/vital_whitelist/snomed/{value}/all')
                     .and_values(values)
                     .error_on_empty(Cdris::Gateway::Exceptions::SnomedCodesNotProvided)

          when :icd9_problem_whitelist
            Whitelist.new
                     .with_template('/problem_whitelist/icd9/{value}/all')
                     .and_values(values)
                     .error_on_empty(Cdris::Gateway::Exceptions::Icd9CodesNotProvided)
          else
            Whitelist.new
          end
        end

        # Array of known whitelists
        #
        # @return [Array] known whitelists
        def self.known_whitelists
          [
            :type_of_service_whitelist,
            :subject_matter_domain_whitelist,
            :with_ejection_fractions,
            :snomed_problem_whitelist,
            :snomed_procedure_whitelist,
            :snomed_vital_whitelist,
            :icd9_problem_whitelist
          ]
        end

        private

        def clinical_or_all
          @whitelist_hash[:clinical] ? 'clinical' : 'all'
        end

      end

    end

  end

end
