require './spec/spec_helper'
require './lib/cdris/gateway/patient_document'
require './lib/cdris/gateway/requestor'
require './lib/cdris/gateway/exceptions'
require 'fakeweb'

describe Cdris::Gateway::PatientDocument do

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  let(:patient_document_path) { 'patient_document_path' }

  describe 'self.data' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/530c9f64e4b02eb001555cfc/data?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_data.to_s)

    it 'requests and returns the expected patient document data' do
      described_class.data(
        {
          :id => '530c9f64e4b02eb001555cfc'
        }).should == { data: DataSamples.patient_document_data.to_s, type: 'text/plain' }
    end

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/i_dont_exist/data?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :status => ['404', 'OK'])

    it 'raises a PatientDocumentNotFoundError when it it receives a 404 after requesting patient document data' do
      expect {
        described_class.data({:id => 'i_dont_exist'})
      }.to raise_error(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
    end

  end

  describe 'self.test_patient_document' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/test_document?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_test_patient_document.to_s)

    it 'requests and returns the expected patient test_patient_document' do
      described_class.test_patient_document.should == DataSamples.patient_document_test_patient_document.to_hash
    end

  end

  describe 'self.text' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/1234/text?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_text.to_s)

    it 'requests and returns the expected patient document text' do
      described_class.text(
      {
        :id => '1234'
      }).should == DataSamples.patient_document_text.to_s
    end

  end

  describe 'self.facts' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_facts.to_s)

    it 'requests and returns the expected patient document facts' do
      described_class.facts(
      {
        :id => '42'
      }).should == DataSamples.patient_document_facts.to_hash
    end

  end

  describe 'self.icd9_problem_codes' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/problems/icd9/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_icd9_problem_codes.to_s)

    it 'requests and returns the expected patient document icd9 problem codes' do
      described_class.icd9_problem_codes(
      {
        :id => '42'
      }, {
        :user => { :root => "foobar", :extension => "spameggs" }
      }).should == DataSamples.patient_document_icd9_problem_codes.to_hash
    end

  end

  describe 'self.icd9_problem_codes_simple' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/icd9?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_icd9_problem_codes_simple.to_s)

    it 'requests and returns the expected simple patient document icd9 problem codes' do
      described_class.icd9_problem_codes_simple(
      {
        :id => '42'
      }, {
        :user => { :root => "foobar", :extension => "spameggs" }
      }).should == DataSamples.patient_document_icd9_problem_codes_simple.to_hash
    end

  end

  describe 'self.snomed_problem_codes' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/problems/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_snomed_problem_codes.to_s)

    it 'requests and returns the expected snomed problem codes' do
      described_class.snomed_problem_codes(
      {
        :id => '42'
      }, {
        :user => { :root => "foobar", :extension => "spameggs" }
      }).should == DataSamples.patient_document_snomed_problem_codes.to_hash
    end

  end

  describe 'self.snomed_problem_codes_clinical' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/problems/snomed/clinical?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_snomed_problem_codes_clinical.to_s)

    it 'requests and returns the expected clinical snomed problem codes' do
      described_class.snomed_problem_codes_clinical(
      {
        :id => '42'
      }, {
        :user => { :root => "foobar", :extension => "spameggs" }
      }).should == DataSamples.patient_document_snomed_problem_codes_clinical.to_hash
    end

  end

  describe 'self.snomed_procedure_codes' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/procedures/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_snomed_procedure_codes.to_s)

    it 'requests and returns the expected snomed procedure codes' do
      described_class.snomed_procedure_codes(
      {
        :id => '42'
      }, {
        :user => { :root => "foobar", :extension => "spameggs" }
      }).should == DataSamples.patient_document_snomed_procedure_codes.to_hash
    end

  end

  describe 'self.ejection_fractions' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/foo/bar/patient_documents/current/with/ejection_fractions?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_ejection_fractions.to_s)

    it 'requests and returns the expected ejection fractions' do
      described_class.ejection_fractions(
      {
        root: 'foo',
        extension: 'bar'
      }, {
        :user => { :root => "foobar", :extension => "spameggs" }
      }).should == DataSamples.patient_document_ejection_fractions.to_hash
    end

  end

  describe 'self.search' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/search?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_search.to_s)

    it 'requests and returns the expected patient document search' do
      described_class.search(
        {
          :user => { :root => "foobar", :extension => "spameggs"}
        }).should == DataSamples.patient_document_search.to_hash
    end

  end

  describe 'self.cluster' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/cluster?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_cluster.to_s)

    it 'requests and returns the expected patient cluster' do
      described_class.cluster(
        {
          :id => 42
        }, {
          :user => { :root => "foobar", :extension => "spameggs"}
        }).should == DataSamples.patient_document_cluster.to_hash
    end

  end

  describe 'self.set' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/set?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_document_set.to_s)

    it 'requests and returns the expected patient set' do
      described_class.set(
        {
          :id => 42
        }, {
          :user => { :root => "foobar", :extension => "spameggs"}
        }).should == DataSamples.patient_document_set.to_hash
    end

  end

end
