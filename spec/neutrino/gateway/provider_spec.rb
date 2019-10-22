require './spec/spec_helper'
require './lib/neutrino/gateway/requestor'
require './lib/neutrino/gateway/exceptions'
require './lib/neutrino/gateway/provider'
require 'fakeweb'

describe Neutrino::Gateway::Provider do

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.create' do

    let(:path) { '/api/v1/provider' }
    let(:body) { { 'name' => 'test_provider' } }
    let(:response_message) { { 'id' => '1', 'name' => 'test_provider' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/provider?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'performs a post request' do
      expect(Neutrino::Gateway::Requestor).to receive(:request).with(path, { method: :post }, body).and_call_original
      expect(described_class.create(body)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/provider?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: 'Invalid Provider', status: ['400', 'Invalid Provider'])
      end

      it 'raises a provider invalid error' do
        expect { described_class.create(body) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderInvalidError)
      end
    end

  end

  describe 'self.show_providers' do

    let(:response_message) { [{ 'id' => '1', 'name' => 'test_provider' }] }

    before(:each) do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/provider?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.show_providers({})).to eq(response_message.to_json)
    end

  end

  describe 'self.get' do

    let(:response_message) { { 'id' => '1', 'name' => 'test_provider' } }

    before(:each) do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.get(id: 1)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/provider/d?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: 'Invalid Provider', status: ['400', 'Invalid Provider'])
      end

      it 'raises a provider invalid error' do
        expect { described_class.get(id: 'd') }.to raise_error(Neutrino::Gateway::Exceptions::ProviderInvalidError)
      end
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: 'Provider Not Found', status: ['404', 'Provider Not Found'])
      end

      it 'raises a provider not found error' do
        expect { described_class.get(id: 1) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderNotFoundError)
      end
    end
  end

  describe 'self.update_by_id' do

    let(:response_message) { { 'id' => '1', 'name' => 'test_provider' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.update_by_id(id: 1)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: 'Invalid Provider', status: ['400', 'Invalid Provider'])
      end

      it 'raises a provider invalid error' do
        expect { described_class.update_by_id(id: 1) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderInvalidError)
      end
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: 'Provider Not Found', status: ['404', 'Provider Not Found'])
      end

      it 'raises a provider not found error' do
        expect { described_class.update_by_id(id: 1) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderNotFoundError)
      end
    end
  end

  describe 'self.delete_by_id' do

    before(:each) do
      FakeWeb.register_uri(
        :delete,
        'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: {}.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.delete_by_id(id: 1).to_hash).to eq({})
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        FakeWeb.register_uri(
          :delete,
          'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: 'Provider Not Found', status: ['404', 'Provider Not Found'])
      end

      it 'raises a Provider not found error' do
        expect { described_class.delete_by_id(id: 1) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderNotFoundError)
      end
    end
  end
end
