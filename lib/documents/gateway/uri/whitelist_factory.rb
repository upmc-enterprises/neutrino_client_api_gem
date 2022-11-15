require 'documents/gateway/exceptions'
require 'documents/gateway/uri/whitelist'

module Neutrino
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
          fail Neutrino::Gateway::Exceptions::BadRequestError if @specified_whitelists.count > 1
          whitelist = @specified_whitelists.first
          values = @whitelist_hash[whitelist]

          case whitelist

          when :type_of_service_whitelist
            Whitelist.new
                     .with_template('/type_of_service_list/{value}')
                     .and_values(values)
                     .error_on_empty(Neutrino::Gateway::Exceptions::TypesOfServiceNotProvided)

          when :subject_matter_domain_whitelist
            Whitelist.new
                     .with_template('/subject_matter_domain_list/{value}')
                     .and_values(values)
                     .error_on_empty(Neutrino::Gateway::Exceptions::SubjectMatterDomainsNotProvided)
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
