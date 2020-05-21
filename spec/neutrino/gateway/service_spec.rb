require './spec/spec_helper'
require './lib/neutrino/gateway/service'
require './lib/neutrino/gateway/requestor'

describe Neutrino::Gateway::Service do

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.data' do

    let(:gi_json_data) { { gi_json_data: 'Some Data' } }
    let(:options) { { debug: true } }
    let(:params) { { patient_document_id: '01123581321', service_class: 'nlp', service_identifier: 'gi' } }

    context 'when valid params are given' do
      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/debug/true/patient_document/01123581321/service/nlp/gi/data?debug=true&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: gi_json_data.to_json)
      end

      it 'gets data' do
        expect((described_class.data(params, options.merge(OPTIONS_WITH_REMOTE_IP)))).to eq({ :data => gi_json_data.to_json, :type => 'text/plain' })
      end
    end

    context 'when no params are given' do
      let(:params) { {} }
      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/debug/true/patient_document/01123581321/service/nlp/gi/data?debug=true&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: {'data' => 'Some Data'}.to_json)
      end

      it 'raises a BadRequestError' do
        expect { described_class.data(params, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::BadRequestError)
      end
    end

    context 'when a document is not found' do
      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/debug/true/patient_document/01123581321/service/nlp/gi/data?debug=true&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(status: [404, 'OK'])
      end

      it 'raises a DerivedWorkDocumentNotFoundError' do
        expect do
          described_class.data(params, options.merge(OPTIONS_WITH_REMOTE_IP))
        end.to raise_error(Neutrino::Gateway::Exceptions::DerivedWorkDocumentNotFoundError)
      end
    end
  end

  describe 'self.metadata' do

    let(:gi_json_data) { { gi_json_data: 'Some Data' } }
    let(:options) { { debug: true } }
    let(:params) { { patient_document_id: '01123581321', service_class: 'nlp', service_identifier: 'gi' } }

    context 'when valid params are given' do
      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/debug/true/patient_document/01123581321/service/nlp/gi?debug=true&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: {'metadata' => 'Some Data'}.to_json)
      end

      it 'gets data' do
        expect((described_class.metadata(params, options.merge(OPTIONS_WITH_REMOTE_IP)))).to eq({ 'metadata' => 'Some Data' })
      end
    end

    context 'when no params are given' do
      let(:params) { {} }
      before(:each) do
        WebMock.stub_request(
            :get,
            'http://testhost:4242/api/v1/debug/true/patient_document/01123581321/service/nlp/gi?debug=true&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
            .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
            .to_return(body: {'data' => 'Some Data'}.to_json)
      end

      it 'raises a BadRequestError' do
        expect { described_class.metadata(params, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::BadRequestError)
      end
    end

    context 'when no document is found' do
      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/debug/true/patient_document/01123581321/service/nlp/gi?debug=true&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(status: [404, 'OK'])
      end

      it 'raises a DerivedWorkDocumentNotFoundError' do
        expect do
          described_class.metadata(params, options.merge(OPTIONS_WITH_REMOTE_IP))
        end.to raise_error(Neutrino::Gateway::Exceptions::DerivedWorkDocumentNotFoundError)
      end
    end
  end

  describe 'self.base_uri' do

    let(:patient_document_id) { '01123581321' }
    let(:service_class) { 'nlp' }
    let(:service_identifier) { 'gi' }
    let(:params) { { patient_document_id: patient_document_id, service_class: service_class, service_identifier: service_identifier } }
    let(:options) { {} }

    context 'when the options specify debugging a valid param combination is specified' do
      let(:options) { { debug: true } }

      it 'returns a URI containing the debug component' do
        expect(described_class.base_uri(params, options)).to match(%r{/debug/true})
      end
    end

    context 'when the params contain :patient_document_id' do
      it 'returns a URI containing the id component' do
        expect(described_class.base_uri(params, options)).to match(%r{/patient_document/#{patient_document_id}})
      end
    end

    context 'when the params contain service_class and service_identifier' do
      it 'returns a URI service_class and service_identifier' do
        expect(described_class.base_uri(params, options)).to match(%r{/service/#{service_class}/#{service_identifier}})
      end
    end

    context 'when service_class and service_identifier are not in params a bad request error is thrown' do
      let(:options) { { debug: true } }
      let(:params) { { patient_document_id: '01123581321' } }

      it 'returns a URI service_class and service_identifier' do
        expect { described_class.base_uri(params, options) }.to raise_error(Neutrino::Gateway::Exceptions::BadRequestError)
      end
    end

    context 'patient_document_id or id are not in params a bad request error is thrown' do
      let(:options) { { debug: true } }
      let(:params) { {} }

      it 'returns a URI service_class and service_identifier' do
        expect { described_class.base_uri(params, options) }.to raise_error(Neutrino::Gateway::Exceptions::BadRequestError)
      end
    end
  end

end
