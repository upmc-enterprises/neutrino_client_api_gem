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
