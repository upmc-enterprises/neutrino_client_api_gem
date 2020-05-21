require './spec/spec_helper'
require './lib/neutrino/gateway/tenants'
require './lib/neutrino/gateway/requestor'

describe Neutrino::Gateway::Tenants do

  let(:base_api) { 'base_api' }

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    it 'gets tenants' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/admin/tenants?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.tenants.to_s)

      expect(described_class.get(OPTIONS_WITH_REMOTE_IP)).to eq(DataSamples.tenants.to_hash)
    end

  end

  describe 'self.find_by_id' do

    let(:response_message) { { 'id' => 1, 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/admin/tenants/1?debug=false&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json)
    end

    it 'returns the expected result' do
      expect(described_class.find_by_id(1, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when it gets a tenant with a secret key' do
      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/admin/tenants/1?debug=true&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: response_message.to_json)
      end

      it 'returns the expected tenant with secret key' do
        expect(described_class.find_by_id(1, OPTIONS_WITH_REMOTE_IP, true)).to eq(response_message)
      end
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/admin/tenants/1?debug=false&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'UnableToRetrieveTenantsError', status: ['400', 'Unable To Retrieve Tenants'])
      end

      it 'raises an error' do
        expect { described_class.find_by_id(1, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::UnableToRetrieveTenantsError)
      end
    end
  end

  describe 'self.create' do

    let(:path) { '/api/v1/admin/tenants' }
    let(:body) { { 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }
    let(:response_message) { { 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      WebMock.stub_request(
        :post,
        'http://testhost:4242/api/v1/admin/tenants?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'performs a post request' do
      expect(Neutrino::Gateway::Requestor).to receive(:request).with(path, { method: :post }.merge(OPTIONS_WITH_REMOTE_IP), body).and_call_original
      expect(described_class.create(body, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

  end

  describe 'self.update_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      WebMock.stub_request(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.update_by_id(1, response_message, OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: '{ "error" : "UnableToUpdateTenantError" }', status: ['400', 'Unable To Update Tenant'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.update_by_id(1, response_message, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::UnableToUpdateTenantError)
      end
    end

    context 'when the server returns a 404 error' do

      before(:each) do
        WebMock.stub_request(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: '{ "error" : "UnableToRetrieveTenantsError" }', status: ['404', 'Unable To Retrieve Tenants'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.update_by_id(1, response_message, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::UnableToRetrieveTenantsError)
      end
    end
  end

end
