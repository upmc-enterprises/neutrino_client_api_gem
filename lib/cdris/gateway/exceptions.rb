module Cdris
  module Gateway
    # The Exceptions module for custom exceptions.
    module Exceptions

      class BaseError < StandardError
        attr_accessor :errors

        def initialize(errors = [], message = '')
          super(message)
          self.errors = errors.class == Array ? errors : [errors]
        end
      end

      class FailedRequestError < BaseError
        attr_accessor :field

        def initialize(field = '', errors = [], message = "")
          super(errors, message)
          self.field = field
        end
      end

      # Error class for when a time isn't formatted correctly.
      class TimeFormatError < BaseError
        attr_accessor :field

        def initialize(field = '', errors = [], message = "Invalid date time. Use format '2012-01-03T05:00:00Z'")
          super(errors, message)
          self.field = field
        end
      end

      # Error class for when a time window is invalid, ie, when the end time comes
      #   before the start time.
      class TimeWindowError < BaseError
        attr_accessor :field

        def initialize(field = '', errors = [], message = 'Invalid time window. Ensure that the ending time is later than the starting time.')
          super(errors, message)
          self.field = field
        end
      end

      # Error class for when an unknown server error occurs.
      class InternalServerError < BaseError
        def initialize(errors = [], message = 'Internal Server Error')
          super(errors, message)
        end
      end

      # Error class for when 401 response code received
      class AuthenticationError < BaseError
        def initialize(errors = [], message = 'Authentication Fail')
          super(errors, message)
        end
      end

      # Error class for when a problem occurs with parsing API parameters.
      class BadRequestError < BaseError
        def initialize(errors = [], message = 'Bad Request')
          super(errors, message)
        end
      end

      # Error class for when something is not found.
      class GenericNotFoundError < BaseError
        def initialize(message = 'Resource Not Found')
          super([], message)
        end
      end

      # Error class for when a patient is not found.
      class PatientNotFoundError < BaseError
        def initialize(errors = [], message = 'Patient Not Found')
          super(errors, message)
        end
      end

      # Error class for when content is not found.
      class ContentNotFoundError < BaseError
        def initialize(errors = [], message = 'Content Not Found')
          super(errors, message)
        end
      end

      # Error class for when a patient document is not found.
      class PatientDocumentNotFoundError < BaseError
        def initialize(errors = [], message = 'Patient Document Not Found')
          super(errors, message)
        end
      end

      # Error class for when a patient identity set is not error.
      class PatientIdentitySetInError < BaseError
        def initialize(errors = [], message = 'Patient Identity Set is in Error')
          super(errors, message)
        end
      end

      # Error class for when a patient identity is not in error.
      class PatientIdentityNotInError < BaseError
        def initialize(errors = [], message = 'Patient Identity Is Not In Error')
          super(errors, message)
        end
      end

      # Error class for when a patient identity has documents.
      class PatientIdentityHasDocumentsError < BaseError
        def initialize(errors = [], message = 'Patient Identity Has Documents')
          super(errors, message)
        end
      end

      # Error class for when a patient identity set is not error.
      class PatientIdentityGatewayNotAuthorizedError < BaseError
        def initialize(errors = [], message = 'Application is not authorized to perform lookup with Patient Identity')
          super(errors, message)
        end
      end

      # Error class for when a patient document is found by confidential.
      class PatientDocumentConfidentialError < BaseError
        def initialize(errors = [], message = 'Patient Document is designated confidential')
          super(errors, message)
        end
      end

      # Error class for when the patient document's source text is not found.
      class PatientDocumentTextNotFoundError < BaseError
        def initialize(errors = [], message = 'Patient Document Text Not Found')
          super(errors, message)
        end
      end

      # Error class for when a nlp patient document source text is not found.
      class NlpPatientDocumentSourceTextNotFoundError < BaseError
        def initialize(errors = [], message = 'Nlp Patient Document Source Text Not Found')
          super(errors, message)
        end
      end

      # Error class for when a derived work document is not found.
      class DerivedWorkDocumentNotFoundError < BaseError
        def initialize(errors = [], message = 'Derived work document not found')
          super(errors, message)
        end
      end

      # Error class for when a nlp patient document is not found.
      class NlpPatientDocumentNotFoundError < BaseError
        def initialize(errors = [], message = 'Nlp Patient Document Not Found')
          super(errors, message)
        end
      end

      # Error class for when nlp annotations are being requested for a non-nlp
      #   document type.
      class DocumentTypeInvalidForNlp < BaseError
        def initialize(errors = [], message = 'Document Type not valid for NLP processing.')
          super(errors, message)
        end
      end

      # Error class for when a mapping is not found.
      class MapTypeNotFoundError < BaseError
        def initialize(errors = [], message = 'Mapping Not Found')
          super(errors, message)
        end
      end

      # Error class for when an invalid mapping is provided.
      class MapTypeInvalidError < BaseError
        def initialize(errors = [], message = 'Invalid Map Type')
          super(errors, message)
        end
      end

      # Error class for when a root is not found.
      class RootNotFoundError < BaseError
        def initialize(errors = [], message = 'Root Not Found')
          super(errors, message)
        end
      end

      # Error class for when an invalid root is provided.
      class RootInvalidError < BaseError
        def initialize(errors = [], message = 'Invalid Root')
          super(errors, message)
        end
      end

      # Error class for when an Azure group is not found.
      class AzureAdGroupNotFoundError < BaseError
        def initialize(errors = [], message = 'AzureAD Group Not Found')
          super(errors, message)
        end
      end

      # Error class for when an invalid Azure group is provided.
      class AzureAdGroupInvalidError < BaseError
        def initialize(errors = [], message = 'Invalid AzureAD Group')
          super(errors, message)
        end
      end

      # Error class for when a Tenant is not found.
      class TenantNotFoundError < BaseError
        def initialize(errors = [], message = 'Tenant Not Found')
          super(errors, message)
        end
      end

      # Error class for when an invalid Tenant is provided.
      class TenantInvalidError < BaseError
        def initialize(errors = [], message = 'Invalid Tenant')
          super(errors, message)
        end
      end

      # Error class for when a named query is not found
      class NamedQueryNotFoundError < BaseError
        def initialize(errors = [], message = 'Named query not found')
          super(errors, message)
        end
      end

      # The parent of various whitelist not found errors
      class WhitelistNotProvidedError < BaseError
        def initialize(errors = [], message = 'Whitelist not provided')
          super(errors, message)
        end
      end

      # Error class for when service types are not provided.
      class TypesOfServiceNotProvided < WhitelistNotProvidedError
        def initialize(errors = [], message = 'Type(s) of service not provided.')
          super(errors, message)
        end
      end

      # Error class for when service types are not provided.
      class PatientDemographicsNotFoundError < BaseError
        def initialize(errors = [], message = 'Patient demographics not found')
          super(errors, message)
        end
      end

      # Error class for when subject matter domains are not provided.
      class SubjectMatterDomainsNotProvided < WhitelistNotProvidedError
        def initialize(errors = [], message = 'Subject matter domain(s) not provided.')
          super(errors, message)
        end
      end

      # Error class for when CDRIS is unable to parse version information
      class UnableToParseVersionInformationError < BaseError
        def initialize(errors = [], message = 'CDRIS was unable to parse version information')
          super(errors, message)
        end
      end

      # Error class for when CDRIS is unable to parse version information
      class UnableToParseVersionHistoryError < BaseError
        def initialize(errors = [], message = 'CDRIS was unable to parse version history')
          super(errors, message)
        end
      end

      # Error class for when Neutrino is unable to create a list of application accounts
      class UnableToCreateApplicationAccountsError < BaseError
        def initialize(errors = [], message = 'CDRIS was unable to create application account')
          super(errors, message)
        end
      end

      # Error class for when Neutrino is unable to retrieve an application account
      class UnableToRetrieveApplicationAccountsError < BaseError
        def initialize(errors = [], message = 'CDRIS was unable to retrieve application accounts')
          super(errors, message)
        end
      end

      # Error class for when Neutrino is unable to unable a list of application accounts
      class UnableToUpdateApplicationAccountsError < BaseError
        def initialize(errors = [], message = 'CDRIS was unable to update application account')
          super(errors, message)
        end
      end

      class UnableToUpdateTenantError < BaseError
        def initialize(errors = [], message = 'CDRIS was unable to update tenant')
          super(errors, message)
        end
      end

      # Error class for when CDRIS is unable to retrieve the list of tenants
      class UnableToRetrieveTenantsError < BaseError
        def initialize(errors = [], message = 'CDRIS was unable to retrieve tenants')
          super(errors, message)
        end
      end

      # Error class for when CDRIS is unable to retrieve configurations
      class UnableToRetrieveConfigurations < BaseError
        def initialize(errors = [], message = 'CDRIS was unable to retrieve configuration')
          super(errors, message)
        end
      end

      class MissingConfiguration < BaseError
        def initialize(errors = [], message = 'Configuration not found')
          super(errors, message)
        end
      end

      # Error class for when an operation is not permitted for a tenant
      class InvalidTenantOperation < BaseError
        def initialize(errors = [], message = 'Operation is not permitted for the tenant')
          super(errors, message)
        end
      end

      # Error class for when an no import file is provded for file import.
      class ImportFileNotProvided < BaseError
        def initialize(errors = [], message = 'No file provided. File expected with key fileUpload.')
          super(errors, message)
        end
      end

      # Error class for when an no import file is provded for file import.
      class ImportFileTypeNotSupported < BaseError
        def initialize(errors = [], message = 'Invalid file type provided.')
          super(errors, message)
        end
      end

      # Error class for when an no import file is provded for file Export.
      class ExportFileTypeNotSupported < BaseError
        def initialize(errors = [], message = 'Invalid file type provided.')
          super(errors, message)
        end
      end

      # Error class for when an invalid file type is requested
      class UnsupportedFileFormatError < BaseError
        def initialize(errors = [], message = 'Invalid File Type')
          super(errors, message)
        end
      end

      # Error class for when there is trouble parsing a JSON response
      class JsonBodyParseError < BaseError
        def initialize(errors = [], message = 'Error parsing JSON body of response')
          super(errors, message)
        end
      end

      # Error class for when invalid access is provided
      class AccessForbiddenError < BaseError
        def initialize(errors = [], message = 'Access Forbidden')
          super(errors, message)
        end
      end

      # Error class for when a tenant is disabled
      class TenantDisabledError < BaseError
        def initialize(errors = [], message = 'Access Forbidden - Current tenant is disabled')
          super(errors, message)
        end
      end

      # Error class for when invalid authentication is provided
      class AuthenticationFailureError < BaseError
        def initialize(errors = [], message = 'Authentication Failure')
          super(errors, message)
        end
      end

      # Error class for when a conversion is not supported
      class DocumentConversionNotSupported < BaseError
        def initialize(errors = [], message = 'Conversion Not Supported')
          super(errors, message)
        end
      end

      # Error class for when a provider is not found.
      class ProviderNotFoundError < BaseError
        def initialize(errors = [], message = 'Provider Not Found')
          super(errors, message)
        end
      end

      # Error class for when an invalid provider is provided.
      class ProviderInvalidError < BaseError
        def initialize(errors = [], message = 'Invalid Provider')
          super(errors, message)
        end
      end

      # Error class for when deleting a root which has associated provider
      class DeleteRootWithProviderError < BaseError
        def initialize(errors = [], message = 'Deletion of a root assigned to a provider is not allowed')
          super(errors, message)
        end
      end

      # Error class for when creating/updating a root with non-existent provider
      class PostRootWithNonExistProviderError < BaseError
        def initialize(errors = [], message = 'Create or update a root with a non-existent provider')
          super(errors, message)
        end
      end
    end
  end
end
