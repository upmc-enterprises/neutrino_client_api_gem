require './spec/spec_helper'
require './lib/documents/gateway/requestor'
require './lib/documents/gateway/exceptions'
require './lib/documents/gateway/root'

describe Documents::Gateway::Root do

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.create' do

    let(:path) { '/api/v1/root' }
    let(:body) { { 'root_type' => 'invalid', 'root' => 'test', 'long_desc' => 'long', 'short_desc' => 'short '} }
    let(:response_message) { { 'id' => '1', 'root_type' => 'invalid', 'root' => 'test', 'long_desc' => 'long', 'short_desc' => 'short ' } }

    before(:each) do
      WebMock.stub_request(
        :post,
        'http://testhost:4242/api/v1/root?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'performs a post request' do
      expect(Documents::Gateway::Requestor).to receive(:request).with(path, { method: :post }.merge(OPTIONS_WITH_REMOTE_IP), body).and_call_original
      expect(described_class.create(body, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the invalid root' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/root?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Root Invalid', status: ['400', 'Root Invalid'])
      end

      it 'raises a root invalid error' do
        expect { described_class.create(body, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::RootInvalidError)
      end
    end

    context 'when associated provider does not exist' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/root?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: '{ "error": "Create or update a root with a non-existent provider" }', status: ['400'])
      end

      it 'raises a PostRootWithNonExistProviderError' do
        expect { described_class.create(body, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::PostRootWithNonExistProviderError)
      end
    end


  end

  describe 'self.show_roots' do

    let(:response_message) { [{ 'id' => '1', 'root_type' => 'invalid', 'root' => 'test', 'long_desc' => 'long', 'short_desc' => 'short' }] }

    before(:each) do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/root?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.show_roots({}, OPTIONS_WITH_REMOTE_IP)).to eq(response_message.to_json)
    end

  end

  describe 'self.get' do

    let(:response_message) { { 'id' => '1', 'root_type' => 'invalid', 'root' => 'test', 'long_desc' => 'long', 'short_desc' => 'short' } }

    before(:each) do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/root/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.get({ id: 1 }, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/root/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Root Invalid', status: ['400', 'Root Invalid'])
      end

      it 'raises a root invalid error' do
        expect { described_class.get({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::RootInvalidError)
      end
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/root/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Root Not Found', status: ['404', 'Root Not Found'])
      end

      it 'raises a root not found error' do
        expect { described_class.get({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::RootNotFoundError)
      end
    end
  end

  describe 'self.update_by_id' do

    let(:response_message) { { 'id' => '1', 'root_type' => 'invalid', 'root' => 'test', 'long_desc' => 'long', 'short_desc' => 'short '} }

    before(:each) do
      WebMock.stub_request(
        :post,
        'http://testhost:4242/api/v1/root/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.update_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/root/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Root Invalid', status: ['400', 'Root Invalid'])
      end

      it 'raises a root invalid error' do
        expect { described_class.update_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::RootInvalidError)
      end
    end

    context 'when associated provider does not exist' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/root/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: '{ "error": "Create or update a root with a non-existent provider" }', status: ['400'])
      end

      it 'raises a root invalid error' do
        expect { described_class.update_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::PostRootWithNonExistProviderError)
      end
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/root/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Root Not Found', status: ['404', 'Root Not Found'])
      end

      it 'raises a root not found error' do
        expect { described_class.update_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::RootNotFoundError)
      end
    end
  end

  describe 'self.delete_by_id' do

    before(:each) do
      WebMock.stub_request(
        :delete,
        'http://testhost:4242/api/v1/root/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: {}.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.delete_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP).to_hash).to eq({})
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        WebMock.stub_request(
          :delete,
          'http://testhost:4242/api/v1/root/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Root Not Found', status: ['404', 'Root Not Found'])
      end

      it 'raises a root not found error' do
        expect { described_class.delete_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::RootNotFoundError)
      end
    end

    context 'when performs a request returning 409 - requested deletion of a root assigned to a provider' do

      before(:each) do
        WebMock.stub_request(
          :delete,
          'http://testhost:4242/api/v1/root/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: '{ "error": "Deletion of a root assigned to a provider is not allowed" }', status: ['409', 'Error'])
      end

      it 'raises DeleteRootWithProviderError' do
        expect { described_class.delete_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::DeleteRootWithProviderError)
      end
    end
  end
end
