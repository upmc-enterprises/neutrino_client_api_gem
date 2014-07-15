require 'bundler/setup'
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
  config.color_enabled = true
  config.formatter = :progress
  config.tty = true
end

# Stub out 'blank?' because ApiAuth.sign! underneath assumes
# that this is a Rails environment, as does Cdris::Api::Client
class Object
  def blank?
    true
  end
end

class DataSamples
  @current = ''

  def self.to_s
    @current
  end

  def self.to_hash
    JSON.parse(@current)
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
    @current = File.read('./spec/fixtures/sample_facts.json')
    self
  end

  def self.patient_document_icd9_problem_codes
    @current = File.read('./spec/fixtures/sample_icd9_problem_codes.json')
    self
  end

  def self.patient_document_icd9_problem_codes_simple
    @current = File.read('./spec/fixtures/sample_icd9_problem_codes_simple.json')
    self
  end

  def self.patient_document_snomed_problem_codes
    @current = File.read('./spec/fixtures/sample_snomed_problem_codes.json')
    self
  end

  def self.patient_document_snomed_vitals
    @current = File.read('./spec/fixtures/sample_snomed_vitals.json')
    self
  end

  def self.patient_document_snomed_problem_codes_clinical
    @current = File.read('./spec/fixtures/sample_snomed_problem_codes_clinical.json')
    self
  end

  def self.patient_document_sample_all_procedures
    @current = File.read('./spec/fixtures/sample_all_procedures.json')
    self
  end

  def self.patient_document_snomed_procedure_codes
    @current = File.read('./spec/fixtures/sample_snomed_procedure_codes.json')
    self
  end

  def self.patient_document_ejection_fractions
    @current = File.read('./spec/fixtures/sample_ejection_fractions.json')
    self
  end

  def self.patient_demographics
    @current = File.read('./spec/fixtures/sample_patient_demographics.json')
    self
  end

  def self.patient_identities
    @current = File.read('./spec/fixtures/sample_patient_identities.json')
    self
  end

  def self.patient_patient_document_search
    @current = File.read('./spec/fixtures/sample_patient_patient_document_search.json')
    self
  end

  def self.patient_patient_document_bounds
    @current = File.read('./spec/fixtures/sample_patient_patient_document_bounds.json')
    self
  end

  def self.patient_subject_matter_domains
    @current = File.read('./spec/fixtures/sample_patient_subject_matter_domains.json')
    self
  end

  def self.patient_types_of_service
    @current = File.read('./spec/fixtures/sample_patient_types_of_service.json')
    self
  end

  def self.patient_document_test_patient_document
    @current = File.read('./spec/fixtures/sample_patient_document_test_patient_document.json')
    self
  end

  def self.patient_document_search
    @current = File.read('./spec/fixtures/sample_patient_document_search.json')
    self
  end

  def self.patient_document_cluster
    @current = File.read('./spec/fixtures/sample_patient_document_cluster.json')
    self
  end

  def self.patient_document_set
    @current = File.read('./spec/fixtures/sample_patient_document_set.json')
    self
  end

  def self.cdris_create_patient_document_error
    @current = File.read('./spec/fixtures/sample_cdris_create_patient_document_error.json')
    self
  end

  def self.info_deployments
    @current = File.read('./spec/fixtures/sample_info_deployments.json')
    self
  end

  def self.info_current_deployment
    @current = File.read('./spec/fixtures/sample_info_current_deployment.json')
    self
  end

  def self.info_configurations
    @current = File.read('./spec/fixtures/sample_info_configurations.json')
    self
  end

  def self.info_configuration
    @current = File.read('./spec/fixtures/sample_info_configuration.json')
    self
  end

  def self.named_query_not_found_error
    @current = File.read('./spec/fixtures/sample_named_query_not_found_error.json')
    self
  end

  def self.named_query_list_of_queries
    @current = File.read('./spec/fixtures/sample_named_query_list_of_queries.json')
    self
  end

  def self.map_type_get
    @current = File.read('./spec/fixtures/sample_map_type_get.json')
    self
  end

  def self.oid_text_get
    @current = File.read('./spec/fixtures/sample_oid_text_get.json')
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