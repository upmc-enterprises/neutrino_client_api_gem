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

      # Error class for when a clu patient document is not found.
      class CluPatientDocumentNotFoundError < BaseError
        def initialize(errors = [], message = 'Clu Patient Document Not Found')
          super(errors, message)
        end
      end

      # Error class for when a clu patient document source text is not found.
      class CluPatientDocumentSourceTextNotFoundError < BaseError
        def initialize(errors = [], message = 'Clu Patient Document Source Text Not Found')
          super(errors, message)
        end
      end

      # Error class for when a search cloud entry is not found.
      class SearchCloudEntryNotFoundError < BaseError
        def initialize(errors = [], message = 'Search Cloud Entry Not Found')
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

      # Error class for when ICD-9 codes are not provided.
      class Icd9CodesNotProvided < WhitelistNotProvidedError
        def initialize(errors = [], message = 'ICD-9 code(s) not provided.')
          super(errors, message)
        end
      end

      # Error class for when SNOMED codes are not provided.
      class SnomedCodesNotProvided < WhitelistNotProvidedError
        def initialize(errors = [], message = 'SNOMED code(s) not provided.')
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

      # Error class for when CDRIS is unable to retrieve configurations
      class UnableToRetrieveConfigurations < BaseError
        def initialize(errors = [], message = 'CDRIS was unable to parse version history')
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
    end
  end
end
