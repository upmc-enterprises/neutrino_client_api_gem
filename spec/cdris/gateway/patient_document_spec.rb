require './spec/spec_helper'
require './lib/cdris/gateway/patient_document'
require './lib/cdris/gateway/requestor'
require './lib/cdris/gateway/exceptions'
require 'fakeweb'

describe Cdris::Gateway::PatientDocument do

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_test_patient_document.to_s)

    it 'requests and returns the expected patient document' do
      described_class.get(id: '42').should == DataSamples.patient_document_test_patient_document.to_hash
    end

  end

  describe 'self.data' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/530c9f64e4b02eb001555cfc/data?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_data.to_s)

    it 'requests and returns the expected patient document data' do
      described_class.data(

          id: '530c9f64e4b02eb001555cfc'
        ).should == { data: DataSamples.patient_document_data.to_s, type: 'text/plain' }
    end

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/i_dont_exist/data?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      status: ['404', 'OK'])

    it 'raises a PatientDocumentNotFoundError when it it receives a 404 after requesting patient document data' do
      expect do
        described_class.data(id: 'i_dont_exist')
      end.to raise_error(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
    end

  end

  describe 'self.test_patient_document' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/test_document?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_test_patient_document.to_s)

    it 'requests and returns the expected patient test_patient_document' do
      described_class.test_patient_document.should == DataSamples.patient_document_test_patient_document.to_hash
    end

  end

  describe 'self.text' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/1234/text?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_text.to_s)

    it 'requests and returns the expected patient document text' do
      described_class.text(

        id: '1234'
      ).should == DataSamples.patient_document_text.to_s
    end

  end

  describe '.original_metadata' do
    subject { described_class.original_metadata(id: document_id) }

    context 'when a non-existent document id is provided' do
      let(:document_id) { 'i_dont_exist' }

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/i_dont_exist/original_metadata?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        status: ['404', 'OK'])

      specify { expect { subject }.to raise_error(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError) }
    end

    context 'when an existent document id is provided' do
      let(:document_id) { 42 }

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/42/original_metadata?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.original_metadata.to_s)

      it 'requests and returns the expected patient document original metadata' do
        subject.should == DataSamples.original_metadata.to_hash
      end
    end
  end

  describe 'self.facts' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_facts.to_s)

    it 'requests and returns the expected patient document facts' do
      described_class.facts(

        id: '42'
      ).should == DataSamples.patient_document_facts.to_hash
    end

  end

  describe 'self.icd9_problem_codes' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/problems/icd9/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_icd9_problem_codes.to_s)

    it 'requests and returns the expected patient document icd9 problem codes' do
      described_class.icd9_problem_codes(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      }).should == DataSamples.patient_document_icd9_problem_codes.to_hash
    end

  end

  describe 'self.icd9_problem_codes_simple' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/icd9?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_icd9_problem_codes_simple.to_s)

    it 'requests and returns the expected simple patient document icd9 problem codes' do
      described_class.icd9_problem_codes_simple(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      }).should == DataSamples.patient_document_icd9_problem_codes_simple.to_hash
    end

  end

  describe 'self.snomed_problem_codes' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/problems/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_snomed_problem_codes.to_s)

    it 'requests and returns the expected snomed problem codes' do
      described_class.snomed_problem_codes(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      }).should == DataSamples.patient_document_snomed_problem_codes.to_hash
    end

  end

  describe 'self.snomed_vitals' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/vitals/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_snomed_vitals.to_s)

    it 'requests and returns the expected snomed vitals' do
      described_class.snomed_vitals(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      }).should == DataSamples.patient_document_snomed_vitals.to_hash
    end

  end

  describe 'self.snomed_problem_codes_clinical' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/problems/snomed/clinical?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_snomed_problem_codes_clinical.to_s)

    it 'requests and returns the expected clinical snomed problem codes' do
      described_class.snomed_problem_codes_clinical(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      }).should == DataSamples.patient_document_snomed_problem_codes_clinical.to_hash
    end

  end

  describe 'self.snomed_procedure_codes' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/procedures/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_snomed_procedure_codes.to_s)

    it 'requests and returns the expected snomed procedure codes' do
      described_class.snomed_procedure_codes(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      }).should == DataSamples.patient_document_snomed_procedure_codes.to_hash
    end

  end

  describe '.procedures' do
    subject { described_class.procedures(id: document_id) }

    context 'when a valid document id is provided' do
      let(:document_id) { 42 }

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/42/facts/procedures?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.patient_document_sample_all_procedures.to_s)

      it 'requests and returns the expected procedures' do
       subject.should == DataSamples.patient_document_sample_all_procedures.to_hash
      end
    end
  end

  describe 'self.ejection_fractions' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/foo/bar/patient_documents/current/with/ejection_fractions?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_ejection_fractions.to_s)

    it 'requests and returns the expected ejection fractions' do
      described_class.ejection_fractions(
      {
        root: 'foo',
        extension: 'bar'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      }).should == DataSamples.patient_document_ejection_fractions.to_hash
    end

    context 'when an id is given' do

      let(:id) { '42' }
      let(:params) { { id: id } }

      it 'performs a request using the patient document (with id) route' do
        Cdris::Gateway::Requestor.stub(:api).and_return('foo')
        Cdris::Gateway::Requestor.should_receive(:request).with(
          %r{/patient_document/#{id}/facts/ejection_fraction},
          anything).and_return({})
        described_class.ejection_fractions(params)
      end

    end

  end

  describe 'self.search' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/search?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_search.to_s)

    it 'requests and returns the expected patient document search' do
      described_class.search(

          user: { root: 'foobar', extension: 'spameggs' }
        ).should == DataSamples.patient_document_search.to_hash
    end

  end

  describe 'self.cluster' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/cluster?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_cluster.to_s)

    it 'requests and returns the expected patient cluster' do
      described_class.cluster(
        {
          id: 42
        }, {
          user: { root: 'foobar', extension: 'spameggs' }
        }).should == DataSamples.patient_document_cluster.to_hash
    end

  end

  describe 'self.set' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/set?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_set.to_s)

    it 'requests and returns the expected patient set' do
      described_class.set(
        {
          id: 42
        }, {
          user: { root: 'foobar', extension: 'spameggs' }
        }).should == DataSamples.patient_document_set.to_hash
    end

  end

  describe 'self.create' do

    it 'performs a post request' do
      Cdris::Gateway::Requestor.should_receive(:request).with(anything, { method: :post }, anything, anything).and_return({})
      described_class.create
    end

    it 'performs a request with the passed body' do
      Cdris::Gateway::Requestor.should_receive(:request).with(anything, anything, 'foobar', anything).and_return({})
      described_class.create('foobar')
    end

    it 'performs a request without basic auth' do
      Cdris::Gateway::Requestor.should_receive(:request).with(anything, anything, anything, false).and_return({})
      described_class.create('foobar')
    end

    context 'when basic auth is requested' do

      it 'performs a request with basic auth' do
        Cdris::Gateway::Requestor.should_receive(:request).with(anything, anything, anything, true).and_return({})
        described_class.create('foobar', {}, true)
      end

    end

  end

  describe 'self.base_uri' do

    context 'when id, root and extension are not given' do

      let(:params) { {} }

      it 'raises a BadRequestError' do
        expect { described_class.base_uri(params) }.to raise_error(Cdris::Gateway::Exceptions::BadRequestError)
      end

    end

    context 'when id is given' do

      let(:id) { '42' }
      let(:params) { { id: id } }

      it 'builds a URI containing the id URI component' do
        described_class.base_uri(params).should match(/\/#{id}/)
      end

      context 'when debug is specified' do

        let(:options) { { debug: true } }

        it 'builds a URI containing the debug URI component' do
          described_class.base_uri(params, options).should match(/\/debug/)
        end

      end

    end

    context 'when root and extension are given' do

      let(:root) { 'some_root' }
      let(:extension) { 'some_extension' }
      let(:params) { { root: root, extension: extension } }

      it 'builds a URI containing the root and extension URI components' do
        described_class.base_uri(params).should match(%r{/#{root}/#{extension}})
      end

      context 'when extension suffix is given' do

        let(:extension_suffix) { 'some_extension_suffix' }
        before(:each) { params[:extension_suffix] = extension_suffix }

        it 'builds a URI containing the extension suffix URI component' do
          described_class.base_uri(params).should match(/\/#{extension_suffix}/)
        end

        context 'when document source updated at is given' do

          let(:document_source_updated_at) { Time.now }
          before(:each) { params[:document_source_updated_at] = document_source_updated_at }

          it 'builds a URI containing the document source updated at URI component' do
            described_class.base_uri(params).should match(/\/#{document_source_updated_at.iso8601(3)}/)
          end

        end

      end

    end

  end

end
