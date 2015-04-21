require 'bundler/setup'
require 'active_support'
require 'active_support/all'
require './lib/cdris/helpers/monkey_patch'
require 'json'

Bundler.setup

require 'simplecov'
SimpleCov.start do
  # exclude libraries used for testing only
  add_filter './lib/cdris/gateway/exceptions.rb'
  add_filter './lib/cdris/helpers/api_auth_modifications.rb'
end
SimpleCov.coverage_dir 'coverage/rspec'

RSpec.configure do |config|
  config.order = 'random'
  config.color = true
  config.formatter = :progress
  config.tty = true
end

Time.zone = 'UTC'

class DataSamples
  @current = ''

  def self.to_s
    @current
  end

  def self.to_hash
    JSON.parse(@current)
  end

  def self.read_fixture(file_name)
    @current = File.read("./spec/fixtures/#{file_name}")
  end

  def self.patient_document_data
    @current = "some\ndocument\ndata"
    self
  end

  def self.patient_document_text
    @current = "some\ndocument\ntext"
    self
  end

  def self.patient_document_facts
    read_fixture('sample_facts.json')
    self
  end

  def self.patient_document_icd9_problem_codes
    read_fixture('sample_icd9_problem_codes.json')
    self
  end

  def self.patient_document_icd10_problem_codes
    read_fixture('sample_icd10_problem_codes.json')
    self
  end

  def self.patient_document_icd9_problem_codes_simple
    read_fixture('sample_icd9_problem_codes_simple.json')
    self
  end

  def self.patient_document_snomed_problem_codes
    read_fixture('sample_snomed_problem_codes.json')
    self
  end

  def self.patient_document_snomed_vitals
    read_fixture('sample_snomed_vitals.json')
    self
  end

  def self.patient_document_snomed_problem_codes_clinical
    read_fixture('sample_snomed_problem_codes_clinical.json')
    self
  end

  def self.patient_document_sample_all_procedures
    read_fixture('sample_all_procedures.json')
    self
  end

  def self.patient_document_snomed_procedure_codes
    read_fixture('sample_snomed_procedure_codes.json')
    self
  end

  def self.patient_document_ejection_fractions
    read_fixture('sample_ejection_fractions.json')
    self
  end

  def self.patient_demographics
    read_fixture('sample_patient_demographics.json')
    self
  end

  def self.patient_identities
    read_fixture('sample_patient_identities.json')
    self
  end

  def self.patient_identities_in_error
    read_fixture('sample_patient_identities_in_error.json')
    self
  end

  def self.patient_patient_document_search
    read_fixture('sample_patient_patient_document_search.json')
    self
  end

  def self.patient_patient_document_bounds
    read_fixture('sample_patient_patient_document_bounds.json')
    self
  end

  def self.patient_subject_matter_domains
    read_fixture('sample_patient_subject_matter_domains.json')
    self
  end

  def self.patient_types_of_service
    read_fixture('sample_patient_types_of_service.json')
    self
  end

  def self.patient_document_test_patient_document
    read_fixture('sample_patient_document_test_patient_document.json')
    self
  end

  def self.tenants
    read_fixture('sample_tenants.json')
    self
  end

  def self.patient_document_search
    read_fixture('sample_patient_document_search.json')
    self
  end

  def self.patient_document_cluster
    read_fixture('sample_patient_document_cluster.json')
    self
  end

  def self.patient_document_set
    read_fixture('sample_patient_document_set.json')
    self
  end

  def self.cdris_create_patient_document_error
    read_fixture('sample_cdris_create_patient_document_error.json')
    self
  end

  def self.info_deployments
    read_fixture('sample_info_deployments.json')
    self
  end

  def self.info_current_deployment
    read_fixture('sample_info_current_deployment.json')
    self
  end

  def self.info_configurations
    read_fixture('sample_info_configurations.json')
    self
  end

  def self.info_configuration
    read_fixture('sample_info_configuration.json')
    self
  end

  def self.named_query_not_found_error
    read_fixture('sample_named_query_not_found_error.json')
    self
  end

  def self.named_query_list_of_queries
    read_fixture('sample_named_query_list_of_queries.json')
    self
  end

  def self.map_type_get
    read_fixture('sample_map_type_get.json')
    self
  end

  def self.oid_text_get
    read_fixture('sample_oid_text_get.json')
    self
  end

  def self.original_metadata
    read_fixture('sample_patient_document_original_metadata.json')
    self
  end

  def self.application_accounts
    read_fixture('sample_application_accounts.json')
    self
  end
end

class TestConfig
  def self.to_hash
    {
      protocol: protocol,
      host: host,
      port: port,
      user_root: user_root,
      user_extension: user_extension,
      api_version: api_version,
      hmac_key: hmac_key,
      hmac_id: hmac_id,
      auth_user: auth_user,
      auth_pass: auth_pass
    }
  end

  def self.protocol
    'http'
  end

  def self.host
    'testhost'
  end

  def self.port
    '4242'
  end

  def self.user_root
    'foobar'
  end

  def self.user_extension
    'spameggs'
  end

  def self.api_version
    '1'
  end

  def self.auth_user
    'john'
  end

  def self.auth_pass
    'doe'
  end

  def self.hmac_id
    '1234'
  end

  def self.hmac_key
    '4321'
  end
end

module ActionDispatch
  module Http
    # Models uploaded files.
    #
    # The actual file is accessible via the +tempfile+ accessor, though some
    # of its interface is available directly for convenience.
    #
    # Uploaded files are temporary files whose lifespan is one request. When
    # the object is finalized Ruby unlinks the file, so there is no need to
    # clean them with a separate maintenance task.
    class UploadedFile
      # The basename of the file in the client.
      attr_accessor :original_filename

      # A string with the MIME type of the file.
      attr_accessor :content_type

      # A +Tempfile+ object with the actual uploaded file. Note that some of
      # its interface is available directly.
      attr_accessor :tempfile
      alias :to_io :tempfile

      # A string with the headers of the multipart request.
      attr_accessor :headers

      def initialize(hash) # :nodoc:
        @tempfile = hash[:tempfile]
        raise(ArgumentError, ':tempfile is required') unless @tempfile

        @original_filename = hash[:filename]
        @content_type = hash[:type]
        @headers = hash[:head]
      end

      # Shortcut for +tempfile.read+.
      def read(length=nil, buffer=nil)
        @tempfile.read(length, buffer)
      end

      # Shortcut for +tempfile.open+.
      def open
        @tempfile.open
      end

      # Shortcut for +tempfile.close+.
      def close(unlink_now=false)
        @tempfile.close(unlink_now)
      end

      # Shortcut for +tempfile.path+.
      def path
        @tempfile.path
      end

      # Shortcut for +tempfile.rewind+.
      def rewind
        @tempfile.rewind
      end

      # Shortcut for +tempfile.size+.
      def size
        @tempfile.size
      end

      # Shortcut for +tempfile.eof?+.
      def eof?
        @tempfile.eof?
      end
    end
  end
end


