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

    context 'When the conversion is not supported' do

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/i_not_supported/data?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        status: ['400', 'OK'])

      it 'raises a DocumentConversionNotSupported when it it receives a 400 after requesting patient document data' do
        expect do
          described_class.data(id: 'i_not_supported')
        end.to raise_error(Cdris::Gateway::Exceptions::DocumentConversionNotSupported)
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

  describe 'self.highlight' do
    let(:params) { { literal: 'exam', format: 'html' } }
    let(:response_body) { { data: DataSamples.patient_document_text.to_s, type: "text/plain" } }

    context 'when a non-existent document id is provided' do

      FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/highlight/20160114.html?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&literal=exam',
      status: ['404', 'Patient Not Found'])

      it 'raises PatientDocumentNotFoundError' do
        expect{described_class.highlight(params.merge(id: 20160114))}.to raise_error(Cdris::Gateway::Exceptions::PatientDocumentNotFoundError)
      end
    end

    context 'when 400 returned' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/highlight/20160113.html?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&literal=exam',
        status: ['400', 'bad request'])

      it 'railse BadRequestError' do
        expect{described_class.highlight(params.merge(id: 20160113))}.to raise_error(Cdris::Gateway::Exceptions::BadRequestError)
      end
    end

    context 'when 403 returned' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/highlight/20160112.html?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&literal=exam',
        status: ['403', 'bad request'])

      it 'railse invalid tentant error' do
        expect{described_class.highlight(params.merge(id: 20160112))}.to raise_error(Cdris::Gateway::Exceptions::InvalidTenantOperation)
      end
    end

    context 'when valid id provided' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/highlight/neutrino.html?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&literal=exam',
        body: DataSamples.patient_document_text.to_s)

      it 'returns the highlight document' do
        expect(described_class.highlight(params.merge(id: 'neutrino'))).to eq(response_body)
      end

    end

  end

  describe 'self.get_by_data_status_and_time_window' do
    let(:params) { { data_status: 'invalid', date_from: '2018-04-03T18:48:38.077Z', date_to: '2018-05-03T18:48:38.077Z' } }
    let(:params_400) { { data_status: 'invalid', date_from: 'invalid', date_to: '2018-05-03T18:48:38.077Z' } }
    let(:params_403) { { data_status: 'no_status', date_from: '2018-04-03T18:48:38.077Z', date_to: '2018-05-03T18:48:38.077Z' } }
    let(:response_body) { ['patient_document1', 'patient_document2'] }

    context 'when 400 returned' do
      FakeWeb.register_uri(
        :get,
        "http://testhost:4242/api/v1/patient_document/invalid/document_creation_between/invalid/2018-05-03T18:48:38.077Z?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar",
        status: ['400', 'bad request'])

      it 'raise BadRequestError' do
        expect{ described_class.get_by_data_status_and_time_window(params_400) }.to raise_error(Cdris::Gateway::Exceptions::BadRequestError)
      end
    end

    context 'when 403 returned' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/no_status/document_creation_between/2018-04-03T18:48:38.077Z/2018-05-03T18:48:38.077Z?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        status: ['403', 'Tenant Operation Not Allowed'])

      it 'railse invalid tentant error' do
        expect{ described_class.get_by_data_status_and_time_window(params_403) }.to raise_error(Cdris::Gateway::Exceptions::InvalidTenantOperation)
      end
    end

    context 'when valid request' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/invalid/document_creation_between/2018-04-03T18:48:38.077Z/2018-05-03T18:48:38.077Z?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: ['patient_document1', 'patient_document2'].to_json)

      it 'returns document list' do
        expect(described_class.get_by_data_status_and_time_window(params)).to eq(response_body)
      end
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

  describe 'self.hl7_document_ids' do
    let(:ids) { [1, 4, 7] }
    api_path = 'http://testhost:4242/api/v1/patient_document/ids/hl7?' +
               'user%5Bextension%5D=spameggs&user%5Broot%5D=foobar'

    context 'for a document root' do

      FakeWeb.register_uri(
        :get,
        "#{api_path}&root=foobar",
        body: [1, 4, 7].to_json)

      it 'requests and returns the expected patient document search' do
        expect(described_class.hl7_document_ids(root: 'foobar')).to eq(ids)
      end

    end

    context 'for a patient root' do

      FakeWeb.register_uri(
          :get,
          "#{api_path}&patient_root=foobar",
          body: [1, 4, 7].to_json)

      it 'requests and returns the expected patient document search' do
        expect(described_class.hl7_document_ids(patient_root: 'foobar')).to eq(ids)
      end

    end

    context 'for a patient root and date range' do

      FakeWeb.register_uri(
          :get,
          "#{api_path}&patient_root=foobar&date_from=2016-09-01&date_to=2016-09-30",
          body: [1, 4, 7].to_json)

      it 'requests and returns the expected patient document search' do
        expect(described_class.hl7_document_ids(patient_root: 'foobar',
                                                date_from: '2016-09-01',
                                                date_to: '2016-09-30')).to eq(ids)
      end

    end

  end

  describe 'self.patient_document_ids' do
    let(:ids) { [1, 4, 7] }

    context 'without a precedence specified' do

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/ids?patient_root=foobar&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: [1, 4, 7].to_json)

      it 'requests and returns the expected patient document ids' do
        expect(described_class.patient_document_ids(patient_root: 'foobar')).to eq(ids)
      end

    end

    context 'with a precedence specified' do

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/ids/primary?patient_root=foobar&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&precedence=primary',
        body: [1, 4, 7].to_json)

      it 'requests and returns the expected patient document ids' do
        expect(described_class.patient_document_ids(patient_root: 'foobar', precedence: 'primary')).to eq(ids)
      end

    end

    context 'with a date range' do

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/patient_document/ids/primary?date_from=2016-09-01&date_to=2016-09-30&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&precedence=primary',
        body: [1, 4, 7].to_json)

      it 'requests and returns the expected patient document ids' do
        expect(described_class.patient_document_ids({ date_from: '2016-09-01', date_to: '2016-09-30', precedence: 'primary' })).to eq(ids)
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

  describe 'self.literal_search' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/search?literal=FizzBuzz&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.patient_document_search.to_s)

    it 'requests and returns the expected patient document literal search' do
      expect(described_class.literal_search('FizzBuzz', { user: { root: 'foobar', extension: 'spameggs' } }
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

  describe 'self.ingestion_errors' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/ingestion_errors?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.ingestion_errors.to_s)

    it 'requests and returns the list of ingestion errors' do
      expect(described_class.ingestion_errors(
        {}, {
          user: { root: 'foobar', extension: 'spameggs' }
        })).to eq(DataSamples.ingestion_errors.to_hash)
    end

  end

  describe 'self.ingestion_error_by_id' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient_document/ingestion_error?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.ingestion_error.to_s)

    it 'requests and returns the ingestion error by id' do
      expect(described_class.ingestion_error_by_id(
        {}, {
        user: { root: 'foobar', extension: 'spameggs' }
      })).to eq(DataSamples.ingestion_error.to_hash)
    end

  end

  describe 'self.get_provider_payer_delta_for_patient' do

    let(:delta_response) { [
        {
            'provider_patient_document_id' => '1',
            'payer_patient_document_id' => '111',
            'patient_document_root' => 'doc.r',
            'patient_document_extension' => 'doc.x',
            'extension_suffix' => '1',
            'data_precedence' => 'primary',
            'document_source_updated_at' => '2015-01-02T11:00:00.102Z'
        },
        {
            'provider_patient_document_id' => '1',
            'payer_patient_document_id' => nil,
            'patient_document_root' => 'doc.r',
            'patient_document_extension' => 'doc.x',
            'extension_suffix' => '1',
            'data_precedence' => 'primary',
            'document_source_updated_at' => '2015-01-02T11:00:00.102Z',
            'not_synchronized_reason' => 'out of eligibility'
        }
    ] }

    let(:patient_root) { 'some_patient_root' }
    let(:patient_extension) { 'some_patient_extension' }
    let(:params) { { patient_root: patient_root, patient_extension: patient_extension } }

    before(:each) do
      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/governor/provider_payer_delta/some_patient_root/some_patient_extension?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: delta_response.to_json)
    end

    it 'returns the expected result' do
      expect(described_class.get_provider_payer_delta_for_patient(params)).to eq(delta_response)
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
          expect(described_class.base_uri(params)).to include("/#{extension_suffix}")
        end

        context 'when document source updated at is given' do

          let(:document_source_updated_at) { Time.now }
          before(:each) { params[:document_source_updated_at] = document_source_updated_at }

          it 'builds a URI containing the document source updated at URI component' do
            expect(described_class.base_uri(params)).to include("/#{document_source_updated_at.iso8601(3)}")
          end

        end

      end

    end

    context 'when only root is given' do

      let(:root) { 'some_root' }
      let(:params) { { root: root } }

      it 'builds a URI containing the root URI components' do
        expect(described_class.base_uri(params)).to match(%r{/#{root}})
      end

      context 'when the root contain special characters' do
        let(:root) { 'some_root/\;:&-_$@' }

        it 'builds a URI containing the root and extension URI components' do
          expect(described_class.base_uri(params)).to include("/#{URI.escape(root)}")
        end

      end

    end

  end

end
