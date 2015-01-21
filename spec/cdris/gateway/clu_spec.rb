require './spec/spec_helper'
require './lib/cdris/gateway/clu'
require './lib/cdris/gateway/requestor'
require 'fakeweb'

describe Cdris::Gateway::Clu do

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.service_running?' do

    it 'returns true for a service that is running' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/nlp/clu/service_test?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        status: ['200', 'OK'])

      expect(described_class.service_running?).to eq(true)
    end

    it 'returns false when the api return a 502' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/nlp/clu/service_test?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        status: ['502', 'OK'])

      expect(described_class.service_running?).to eq(false)
    end

  end

  describe 'self.document' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/clu_patient_document/42?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: '{}')

    it 'gets a document' do
      expect(described_class.document(id: '42')).to eq(JSON.parse('{}'))
    end

    let(:empty_params) { {} }

    it 'raises a BadRequestError when no params are given' do
      expect { described_class.document(empty_params) }.to raise_error(Cdris::Gateway::Exceptions::BadRequestError)
    end

  end

  describe 'self.data' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/clu_patient_document/42/data?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: 'Some Data')

    it 'gets data' do
      expect(described_class.data(id: '42')).to eq({ data: 'Some Data', type: 'text/plain' })
    end

    let(:empty_params) { {} }

    it 'raises a BadRequestError when no params are given' do
      expect { described_class.data(empty_params) }.to raise_error(Cdris::Gateway::Exceptions::BadRequestError)
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

  end

end
