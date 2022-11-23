require './spec/spec_helper'
require './lib/documents/gateway/requestor'
require './lib/documents/gateway/exceptions'
require './lib/documents/gateway/azure_ad_group'

describe Documents::Gateway::AzureAdGroup do

  before(:each) do
    Documents::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.create' do

    let(:path) { '/api/v1/admin/azure_ad_group' }
    let(:body) { { 'access_level' => 'AR', 'enviroment' => 'development', 'application' => 'documents', 'guid' => '8945f9a9-c886-41c5-b851-deb5f87467f2', 'id' => '1' } }
    let(:response_message) { { 'access_level' => 'AR', 'enviroment' => 'development', 'application' => 'documents', 'guid' => '8945f9a9-c886-41c5-b851-deb5f87467f2', 'id' => '1' } }

    before(:each) do
      WebMock.stub_request(
        :post,
        'http://testhost:4242/api/v1/admin/azure_ad_group?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'performs a post request' do
      expect(Documents::Gateway::Requestor).to receive(:request).with(path, { method: :post, remote_ip: REMOTE_IP }, body).and_call_original
      expect(described_class.create(body, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

  end

  describe 'self.show_azure_ad_groups' do

    let(:response_message) { { 'access_level' => 'AR', 'enviroment' => 'development', 'application' => 'documents', 'guid' => '8945f9a9-c886-41c5-b851-deb5f87467f2', 'id' => '1' } }

    before(:each) do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/admin/azure_ad_group?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.show_azure_ad_groups(OPTIONS_WITH_REMOTE_IP)).to eq(response_message.to_json)
    end

  end

  describe 'self.get' do

    let(:response_message) { { 'access_level' => 'AR', 'enviroment' => 'development', 'application' => 'documents', 'guid' => '8945f9a9-c886-41c5-b851-deb5f87467f2', 'id' => '1' } }

    before(:each) do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/admin/azure_ad_group/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.get({ id: 1 }, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/admin/azure_ad_group/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'AzureAD Group Invalid', status: ['400', 'AzureAD Group Invalid'])
      end

      it 'raises an access level invalid error' do
        expect { described_class.get({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::AzureAdGroupInvalidError)
      end
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/admin/azure_ad_group/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'AzureAD Group Not Found', status: ['404', 'AzureAD Group Not Found'])
      end

      it 'raises an azure group not found error' do
        expect { described_class.get({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::AzureAdGroupNotFoundError)
      end
    end
  end

  describe 'self.update_by_id' do

    let(:response_message) { { 'access_level' => 'AR', 'enviroment' => 'development', 'application' => 'documents', 'guid' => '8945f9a9-c886-41c5-b851-deb5f87467f2', 'id' => '1' } }

    before(:each) do
      WebMock.stub_request(
        :post,
        'http://testhost:4242/api/v1/admin/azure_ad_group/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.update_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/admin/azure_ad_group/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'AzureAD Group Invalid', status: ['400', 'AzureAD Group Invalid'])
      end

      it 'raises an azure group invalid error' do
        expect { described_class.update_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::AzureAdGroupInvalidError)
      end
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/admin/azure_ad_group/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'AzureAD Group Not Found', status: ['404', 'AzureAD Group Not Found'])
      end

      it 'raises an azure group not found error' do
        expect { described_class.update_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::AzureAdGroupNotFoundError)
      end
    end
  end

  describe 'self.delete_by_id' do

    before(:each) do
      WebMock.stub_request(
        :delete,
        'http://testhost:4242/api/v1/admin/azure_ad_group/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
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
          'http://testhost:4242/api/v1/admin/azure_ad_group/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'AzureAD Group Not Found', status: ['404', 'AzureAD Group Not Found'])
      end

      it 'raises an azure group not found error' do
        expect { described_class.delete_by_id({ id: 1 }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::AzureAdGroupNotFoundError)
      end
    end
  end
end
