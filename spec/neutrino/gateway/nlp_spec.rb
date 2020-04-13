require './spec/spec_helper'
require './lib/neutrino/gateway/nlp'
require './lib/neutrino/gateway/requestor'

describe Neutrino::Gateway::Nlp do

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.service_running?' do

    it 'returns true for a service that is running' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/nlp/hf_reveal/service_test?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .to_return(status: ['200', 'OK'])

      expect(described_class.service_running?).to eq(true)
    end

    it 'returns false when the api return a 502' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/nlp/hf_reveal/service_test?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .to_return(status: ['502', 'OK'])

      expect(described_class.service_running?).to eq(false)
    end

  end

  describe 'self.document' do

    it 'gets a document' do
      WebMock.stub_request(
      :get,
      'http://testhost:4242/api/v1/nlp_patient_document/42?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
      .to_return(body: '{}')
      expect(described_class.document(id: '42')).to eq(JSON.parse('{}'))
    end

    let(:empty_params) { {} }

    it 'raises a BadRequestError when no params are given' do
      expect { described_class.document(empty_params) }.to raise_error(Neutrino::Gateway::Exceptions::BadRequestError)
    end

  end

  describe 'self.data' do

    it 'gets data' do
      WebMock.stub_request(
      :get,
      'http://testhost:4242/api/v1/nlp_patient_document/42/data?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
      .to_return(body: 'Some Data')
      expect(described_class.data(id: '42')).to eq({ data: 'Some Data', type: 'text/plain' })
    end

    let(:empty_params) { {} }

    it 'raises a BadRequestError when no params are given' do
      expect { described_class.data(empty_params) }.to raise_error(Neutrino::Gateway::Exceptions::BadRequestError)
    end

  end

  describe 'self.base_uri' do

    let(:params) { {} }
    let(:options) { {} }

    context 'when the options specify debugging a valid param combination is specified' do

      before(:each) do
        options[:debug] = true
        params[:id] = '254321651'
      end

      it 'returns a URI containing the debug component' do
        expect(described_class.base_uri(params, options)).to match(%r{/debug/true})
      end

    end

    context 'when the params contain :patient_document_id' do

      let(:patient_document_id) { '4242424242' }

      before(:each) do
        params[:patient_document_id] = patient_document_id
      end

      it 'returns a URI containing the id component' do
        expect(described_class.base_uri(params, options)).to match(%r{/patient_document_id/#{patient_document_id}})
      end

    end

    context 'when the params contain :transaction_id' do

      let(:transaction_id) { '1212121212' }

      before(:each) do
        params[:transaction_id] = transaction_id
      end

      it 'returns a URI containing the id component' do
        expect(described_class.base_uri(params, options)).to match(%r{/transaction_id/#{transaction_id}})
      end

    end

  end

end
