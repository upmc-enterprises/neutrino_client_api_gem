require './spec/spec_helper'
require './lib/documents/gateway/requestor'
require './lib/documents/gateway/exceptions'
require './lib/documents/gateway/provider'

describe Neutrino::Gateway::Provider do

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.create' do

    let(:path) { '/api/v1/provider' }
    let(:body) { { 'name' => 'test_provider' } }
    let(:response_message) { { 'id' => '1', 'name' => 'test_provider' } }

    before(:each) do
      WebMock.stub_request(
        :post,
        'http://testhost:4242/api/v1/provider?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: [200, 'OK'])
    end

    it 'performs a post request' do
      expect(Neutrino::Gateway::Requestor).to receive(:request).with(path, { method: :post }.merge(OPTIONS_WITH_REMOTE_IP), body).and_call_original
      expect(described_class.create(body, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/provider?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Invalid Provider', status: [400, 'Invalid Provider'])
      end

      it 'raises a provider invalid error' do
        expect { described_class.create(body, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderInvalidError)
      end
    end

  end

  describe 'self.show_providers' do

    let(:response_message) { [{ 'id' => '1', 'name' => 'test_provider' }] }

    before(:each) do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/provider?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: [200, 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.show_providers({}, OPTIONS_WITH_REMOTE_IP)).to eq(response_message.to_json)
    end

  end

  describe 'self.get' do

    let(:response_message) { { 'id' => '1', 'name' => 'test_provider' } }

    before(:each) do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: [200, 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.get({ id: 1 }, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/provider/d?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Invalid Provider', status: [400, 'Invalid Provider'])
      end

      it 'raises a provider invalid error' do
        expect { described_class.get({ id: 'd' }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderInvalidError)
      end
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Provider Not Found', status: [404, 'Provider Not Found'])
      end

      it 'raises a provider not found error' do
        expect { described_class.get({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderNotFoundError)
      end
    end
  end

  describe 'self.update_by_id' do

    let(:response_message) { { 'id' => '1', 'name' => 'test_provider' } }

    before(:each) do
      WebMock.stub_request(
        :post,
        'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: [200, 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.update_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Invalid Provider', status: [400, 'Invalid Provider'])
      end

      it 'raises a provider invalid error' do
        expect { described_class.update_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderInvalidError)
      end
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Provider Not Found', status: [404, 'Provider Not Found'])
      end

      it 'raises a provider not found error' do
        expect { described_class.update_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderNotFoundError)
      end
    end
  end

  describe 'self.delete_by_id' do

    before(:each) do
      WebMock.stub_request(
        :delete,
        'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: {}.to_json, status: [200, 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.delete_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP).to_hash).to eq({})
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        WebMock.stub_request(
          :delete,
          'http://testhost:4242/api/v1/provider/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Provider Not Found', status: [404, 'Provider Not Found'])
      end

      it 'raises a Provider not found error' do
        expect { described_class.delete_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::ProviderNotFoundError)
      end
    end
  end
end
