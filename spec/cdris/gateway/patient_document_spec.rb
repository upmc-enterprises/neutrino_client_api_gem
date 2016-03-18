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
      expect(described_class.get(id: '42')).to eq(DataSamples.patient_document_test_patient_document.to_hash)
    end

  end

  describe 'self.data' do
    formats = { html: 'text/html', rtf: 'text/rtf', pdf: 'application/pdf', txt: 'text/plain' }
    doc_id = '530c9f64e4b02eb001555cfc'
    doc_url = "http://testhost:4242/api/v1/patient_document/#{doc_id}"
    query_string = '?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar'

    context 'When a document exists' do

      FakeWeb.register_uri(:get, "#{doc_url}/data#{query_string}", body: DataSamples.patient_document_data.to_s)

      it 'returns the expected patient document data' do
        expect(described_class.data(id: doc_id)).to eq(
          { data: DataSamples.patient_document_data.to_s, type: 'text/plain' })
      end

      formats.each do |format, type|
        context "and #{format} is the requested format" do

          FakeWeb.register_uri(:get, "#{doc_url}/data.#{format}#{query_string}",
            body: "#{format} data", content_type: type)

          it 'returns the expected patient document data' do
            expect(described_class.data(id: doc_id, format: format)).to eq(
              { data: "#{format} data", type: type })
          end
        end

      end

    end

    context 'When a document does not exist' do

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

  end

  describe 'self.test_patient_document' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/test_document?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_test_patient_document.to_s)

    it 'requests and returns the expected patient test_patient_document' do
      expect(described_class.test_patient_document).to eq(DataSamples.patient_document_test_patient_document.to_hash)
    end

  end

  describe 'self.text' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/1234/text?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_text.to_s)

    it 'requests and returns the expected patient document text' do
      expect(described_class.text(

        id: '1234'
      )).to eq(DataSamples.patient_document_text.to_s)
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
        expect(subject).to eq(DataSamples.original_metadata.to_hash)
      end
    end
  end

  describe '.patient_demographics' do
    subject { described_class.patient_demographics(params) }

    context 'when a patient document exists' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/42/patient_demographics?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.patient_demographics.to_s)

      context 'and a non-existent id is queried for' do
        let(:params) { { id: '35' } }

        FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/patient_document/35/patient_demographics?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          status: 404)

        specify { expect { subject }.to raise_error(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError) }
      end

      context 'and its id is queried for' do
        let(:params) { { id: '42' } }

        it 'gets the patient documents from CDRIS and returns them as a hash' do
          expect(subject).to eq(DataSamples.patient_demographics.to_hash)
        end
      end
    end
  end

  describe 'self.facts' do

    context 'when NLP annotations are available' do

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/42/facts?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.patient_document_facts.to_s)

      it 'requests and returns the expected patient document facts' do
        expect(described_class.facts(id: '42')).to eq(DataSamples.patient_document_facts.to_hash)
      end

    end

    context 'when NLP annotations are not available' do

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/patient_document/43/facts?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: { 'error' => 'Search Cloud Entry Not Found',
                  'errors' => [] }.to_json,
          status: ['404', 'Not Found']
      )

      it 'raises a search cloud not found error' do
        expect {
          described_class.facts(id: '43')
        }.to raise_error(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
      end

    end

  end

  describe 'self.icd9_problem_codes' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/problems/icd9/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_icd9_problem_codes.to_s)

    it 'requests and returns the expected patient document icd9 problem codes' do
      expect(described_class.icd9_problem_codes(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      })).to eq(DataSamples.patient_document_icd9_problem_codes.to_hash)
    end

    context 'when NLP annotations are not available' do

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/patient_document/43/facts/problems/icd9/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: { 'error' => 'Search Cloud Entry Not Found',
                  'errors' => [] }.to_json,
          status: ['404', 'Not Found']
      )

      it 'raises a search cloud not found error' do
        expect {
          described_class.icd9_problem_codes(id: '43')
        }.to raise_error(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
      end

    end

  end

  describe 'self.icd10_problem_codes' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/problems/icd10/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_icd10_problem_codes.to_s)

    it 'requests and returns the expected patient document icd10 problem codes' do
      expect(described_class.icd10_problem_codes(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      })).to eq(DataSamples.patient_document_icd10_problem_codes.to_hash)
    end

    context 'when NLP annotations are not available' do

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/patient_document/43/facts/problems/icd10/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: { 'error' => 'Search Cloud Entry Not Found',
                  'errors' => [] }.to_json,
          status: ['404', 'Not Found']
      )

      it 'raises a search cloud not found error' do
        expect {
          described_class.icd10_problem_codes(id: '43')
        }.to raise_error(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
      end

    end

  end

  describe 'self.icd9_problem_codes_simple' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/icd9?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_icd9_problem_codes_simple.to_s)

    it 'requests and returns the expected simple patient document icd9 problem codes' do
      expect(described_class.icd9_problem_codes_simple(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      })).to eq(DataSamples.patient_document_icd9_problem_codes_simple.to_hash)
    end

    context 'when NLP annotations are not available' do

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/patient_document/43/facts/icd9?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: { 'error' => 'Search Cloud Entry Not Found',
                  'errors' => [] }.to_json,
          status: ['404', 'Not Found']
      )

      it 'raises a search cloud not found error' do
        expect {
          described_class.icd9_problem_codes_simple(id: '43')
        }.to raise_error(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
      end

    end

  end

  describe 'self.snomed_problem_codes' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/problems/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_snomed_problem_codes.to_s)

    it 'requests and returns the expected snomed problem codes' do
      expect(described_class.snomed_problem_codes(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      })).to eq(DataSamples.patient_document_snomed_problem_codes.to_hash)
    end

    context 'when NLP annotations are not available' do

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/patient_document/43/facts/problems/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: { 'error' => 'Search Cloud Entry Not Found',
                  'errors' => [] }.to_json,
          status: ['404', 'Not Found']
      )

      it 'raises a search cloud not found error' do
        expect {
          described_class.snomed_problem_codes(id: '43')
        }.to raise_error(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
      end

    end

  end

  describe 'self.snomed_vitals' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/vitals/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_snomed_vitals.to_s)

    it 'requests and returns the expected snomed vitals' do
      expect(described_class.snomed_vitals(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      })).to eq(DataSamples.patient_document_snomed_vitals.to_hash)
    end

    context 'when NLP annotations are not available' do

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/patient_document/43/facts/vitals/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: { 'error' => 'Search Cloud Entry Not Found',
                  'errors' => [] }.to_json,
          status: ['404', 'Not Found']
      )

      it 'raises a search cloud not found error' do
        expect {
          described_class.snomed_vitals(id: '43')
        }.to raise_error(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
      end

    end

  end

  describe 'self.snomed_problem_codes_clinical' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/problems/snomed/clinical?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_snomed_problem_codes_clinical.to_s)

    it 'requests and returns the expected clinical snomed problem codes' do
      expect(described_class.snomed_problem_codes_clinical(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      })).to eq(DataSamples.patient_document_snomed_problem_codes_clinical.to_hash)
    end

    context 'when NLP annotations are not available' do

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/patient_document/43/facts/problems/snomed/clinical?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: { 'error' => 'Search Cloud Entry Not Found',
                  'errors' => [] }.to_json,
          status: ['404', 'Not Found']
      )

      it 'raises a search cloud not found error' do
        expect {
          described_class.snomed_problem_codes_clinical(id: '43')
        }.to raise_error(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
      end

    end

  end

  describe 'self.snomed_procedure_codes' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/facts/procedures/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_snomed_procedure_codes.to_s)

    it 'requests and returns the expected snomed procedure codes' do
      expect(described_class.snomed_procedure_codes(
      {
        id: '42'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      })).to eq(DataSamples.patient_document_snomed_procedure_codes.to_hash)
    end

    context 'when NLP annotations are not available' do

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/patient_document/43/facts/procedures/snomed/all?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: { 'error' => 'Search Cloud Entry Not Found',
                  'errors' => [] }.to_json,
          status: ['404', 'Not Found']
      )

      it 'raises a search cloud not found error' do
        expect {
          described_class.snomed_procedure_codes(id: '43')
        }.to raise_error(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
      end

    end

  end

  describe '.procedures' do
    subject { described_class.procedures({ id: document_id }) }

    context 'when a valid document id is provided' do
      let(:document_id) { 42 }

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/42/facts/procedures?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.patient_document_sample_all_procedures.to_s)

       it { should == DataSamples.patient_document_sample_all_procedures.to_hash }

    end

    context 'when NLP annotations are not available' do

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/patient_document/43/facts/procedures?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: { 'error' => 'Search Cloud Entry Not Found',
                  'errors' => [] }.to_json,
          status: ['404', 'Not Found']
      )

      it 'raises a search cloud not found error' do
        expect {
          described_class.procedures(id: '43')
        }.to raise_error(Cdris::Gateway::Exceptions::SearchCloudEntryNotFoundError)
      end

    end

  end

  describe 'self.ejection_fractions' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/foo/bar/patient_documents/current/with/ejection_fractions?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_ejection_fractions.to_s)

    it 'requests and returns the expected ejection fractions' do
      expect(described_class.ejection_fractions(
      {
        root: 'foo',
        extension: 'bar'
      }, {
        user: { root: 'foobar', extension: 'spameggs' }
      })).to eq(DataSamples.patient_document_ejection_fractions.to_hash)
    end

    context 'when an id is given' do
      let(:id) { '42' }
      let(:params) { { id: id } }
      let(:request) { double('Request') }

      before(:each) do
        allow(Cdris::Gateway::Requestor).to receive(:api).and_return('foo')
        allow(request).to receive(:if_404_raise).and_return(request)
        allow(request).to receive(:to_hash).and_return({})
      end

      it 'performs a request using the patient document (with id) route' do
        expect(Cdris::Gateway::Requestor).to receive(:request).with(
          %r{/patient_document/#{id}/facts/ejection_fraction},
          anything).and_return(request)
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
      expect(described_class.search(

          user: { root: 'foobar', extension: 'spameggs' }
        )).to eq(DataSamples.patient_document_search.to_hash)
    end

  end

  describe 'self.cluster' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/cluster?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_cluster.to_s)

    it 'requests and returns the expected patient cluster' do
      expect(described_class.cluster(
        {
          id: 42
        }, {
          user: { root: 'foobar', extension: 'spameggs' }
        })).to eq(DataSamples.patient_document_cluster.to_hash)
    end

  end

  describe 'self.set' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/42/set?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_set.to_s)

    it 'requests and returns the expected patient set' do
      expect(described_class.set(
        {
          id: 42
        }, {
          user: { root: 'foobar', extension: 'spameggs' }
        })).to eq(DataSamples.patient_document_set.to_hash)
    end

  end

  describe 'self.create' do

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/patient_document?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.patient_document_test_patient_document.to_s, status: ['200', 'OK'])
    end

    it 'performs a post request' do
      expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, { method: :post }, anything, anything).and_call_original
      expect(described_class.create).to eq(DataSamples.patient_document_test_patient_document.to_hash)
    end

    it 'performs a request with the passed body' do
      expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, anything, 'foobar', anything).and_call_original
      expect(described_class.create('foobar')).to eq(DataSamples.patient_document_test_patient_document.to_hash)
    end

    it 'performs a request without basic auth' do
      expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, anything, anything, false).and_call_original
      expect(described_class.create('foobar')).to eq(DataSamples.patient_document_test_patient_document.to_hash)
    end

    context 'when basic auth is requested' do

      FakeWeb.register_uri(
        :post,
        'http://john:doe@testhost:4242/api/v1/patient_document?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.patient_document_test_patient_document.to_s, status: ['200', 'OK'])

      it 'performs a request with basic auth' do
        expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, anything, anything, true).and_call_original
        expect(described_class.create('foobar', {}, true)).to eq(DataSamples.patient_document_test_patient_document.to_hash)
      end

    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/patient_document?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: DataSamples.patient_document_test_patient_document.to_s, status: ['400', 'Bad Request'])
      end

      it 'raises a bad request error' do
        expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, anything, anything, anything).and_call_original
        expect { described_class.create }.to raise_error(Cdris::Gateway::Exceptions::BadRequestError)
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
        expect(described_class.base_uri(params)).to match(/\/#{id}/)
      end

      context 'when debug is specified' do

        let(:options) { { debug: true } }

        it 'builds a URI containing the debug URI component' do
          expect(described_class.base_uri(params, options)).to match(/\/debug/)
        end

      end

    end

    context 'when root and extension are given' do

      let(:root) { 'some_root' }
      let(:extension) { 'some_extension' }
      let(:params) { { root: root, extension: extension } }

      it 'builds a URI containing the root and extension URI components' do
        expect(described_class.base_uri(params)).to match(%r{/#{root}/#{extension}})
      end

      context 'when the root and extension contain special characters' do
        let(:root) { 'some_root/\;:&-_$@' }
        let(:extension) { 'some_extension/\;:&-_$@' }

        it 'builds a URI containing the root and extension URI components' do
          expect(described_class.base_uri(params)).to include("/#{URI.escape(root)}/#{URI.escape(extension)}")
        end

      end

      context 'when extension suffix is given' do

        let(:extension_suffix) { 'some_extension_suffix' }
        before(:each) { params[:extension_suffix] = extension_suffix }

        it 'builds a URI containing the extension suffix URI component' do
          expect(described_class.base_uri(params)).to match(/\/#{extension_suffix}/)
        end

        context 'when document source updated at is given' do

          let(:document_source_updated_at) { Time.now }
          before(:each) { params[:document_source_updated_at] = document_source_updated_at }

          it 'builds a URI containing the document source updated at URI component' do
            expect(described_class.base_uri(params)).to match(/\/#{document_source_updated_at.iso8601(3)}/)
          end

        end

      end

    end

  end

end
