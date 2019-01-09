require './spec/spec_helper'
require './lib/cdris/gateway/tenants'
require './lib/cdris/gateway/requestor'
require 'fakeweb'

describe Cdris::Gateway::Tenants do

  let(:base_api) { 'base_api' }

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    it 'gets tenants' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/admin/tenants?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.tenants.to_s)

      expect(described_class.get).to eq(DataSamples.tenants.to_hash)
    end

  end

  describe 'self.find_by_id' do

    let(:response_message) { { 'id' => 1, 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/admin/tenants/1?debug=false&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json)
    end

    it 'returns the expected result' do
      expect(described_class.find_by_id(1)).to eq(response_message)
    end

    context 'when it gets a tenant with a secret key' do
      before(:each) do
        FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/admin/tenants/1?debug=true&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: response_message.to_json)
      end

      it 'returns the expected tenant with secret key' do
        expect(described_class.find_by_id(1, true)).to eq(response_message)
      end
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/admin/tenants/1?debug=false&user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: 'UnableToRetrieveTenantsError', status: ['400', 'Unable To Retrieve Tenants'])
      end

      it 'raises an error' do
        expect { described_class.find_by_id(1) }.to raise_error(Cdris::Gateway::Exceptions::UnableToRetrieveTenantsError)
      end
    end
  end

  describe 'self.create' do

    let(:path) { '/api/v1/admin/tenants' }
    let(:body) { { 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }
    let(:response_message) { { 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'performs a post request' do
      expect(Cdris::Gateway::Requestor).to receive(:request).with(path, { method: :post }, body).and_call_original
      expect(described_class.create(body)).to eq(response_message)
    end

  end

  describe 'self.enable_tenant_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/tenant_enable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.enable_tenant_by_id(1, response_message)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/tenant_enable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: '{ "error" : "UnableToEnableTenantEnabledError" }', status: ['400', 'Unable To Enable Tenant Enabled'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.enable_tenant_by_id(1, response_message) }.to raise_error(Cdris::Gateway::Exceptions::UnableToEnableTenantEnabledError)
      end
    end
  end

  describe 'self.disable_tenant_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'false', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/tenant_disable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.disable_tenant_by_id(1, response_message)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/tenant_disable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: '{ "error" : "UnableToDisableTenantEnabledError" }', status: ['400', 'Unable To Disable Tenant Enabled'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.disable_tenant_by_id(1, response_message) }.to raise_error(Cdris::Gateway::Exceptions::UnableToDisableTenantEnabledError)
      end
    end
  end

  describe 'self.enable_indexing_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/indexing_enable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.enable_indexing_by_id(1, response_message)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/indexing_enable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: '{ "error" : "UnableToEnableIndexingEnabledError" }', status: ['400', 'Unable To Enable Indexing Enabled'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.enable_indexing_by_id(1, response_message) }.to raise_error(Cdris::Gateway::Exceptions::UnableToEnableIndexingEnabledError)
      end
    end
  end

  describe 'self.disable_indexing_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'false', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/indexing_disable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.disable_indexing_by_id(1, response_message)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/indexing_disable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: '{ "error" : "UnableToDisableIndexingEnabledError" }', status: ['400', 'Unable To Disable Indexing Enabled'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.disable_indexing_by_id(1, response_message) }.to raise_error(Cdris::Gateway::Exceptions::UnableToDisableIndexingEnabledError)
      end
    end

  end

  describe 'self.enable_gi_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/gi_enable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.enable_gi_by_id(1, response_message)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/gi_enable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: '{ "error" : "UnableToEnableGiEnabledError" }', status: ['400', 'Unable To Enable GI Enabled'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.enable_gi_by_id(1, response_message) }.to raise_error(Cdris::Gateway::Exceptions::UnableToEnableGiEnabledError)
      end
    end

  end

  describe 'self.disable_gi_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'false', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/gi_disable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.disable_gi_by_id(1, response_message)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/gi_disable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: '{ "error" : "UnableToDisableGiEnabledError" }', status: ['400', 'Unable To Disable GI Enabled'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.disable_gi_by_id(1, response_message) }.to raise_error(Cdris::Gateway::Exceptions::UnableToDisableGiEnabledError)
      end
    end

  end

  describe 'self.enable_hf_reveal_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/hf_reveal_enable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.enable_hf_reveal_by_id(1, response_message)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/hf_reveal_enable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: '{ "error" : "UnableToEnableHfRevealEnabledError" }', status: ['400', 'Unable To Enable HF Reveal Enabled'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.enable_hf_reveal_by_id(1, response_message) }.to raise_error(Cdris::Gateway::Exceptions::UnableToEnableHfRevealEnabledError)
      end
    end

  end

  describe 'self.disable_hf_reveal_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true', 'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'false' } }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/hf_reveal_disable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.disable_hf_reveal_by_id(1, response_message)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/hf_reveal_disable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: '{ "error" : "UnableToDisableHfRevealEnabledError" }', status: ['400', 'Unable To Disable HF Reveal Enabled'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.disable_hf_reveal_by_id(1, response_message) }.to raise_error(Cdris::Gateway::Exceptions::UnableToDisableHfRevealEnabledError)
      end
    end

  end

  describe 'self.enable_patient_identity_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true',
                               'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true', 'patient_identity_disabled' => 'true' } }
    let(:expected_error) { Cdris::Gateway::Exceptions::UnableToEnablePatientIdentityDisabledError }
    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/patient_identity_enable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.enable_patient_identity_by_id(1, response_message)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/patient_identity_enable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: '{ "error" : "UnableToEnablePatientIdentityDisabledError" }', status: ['400', 'Unable To Enable Patient Identity Disabled'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.enable_patient_identity_by_id(1, response_message) }.to raise_error(expected_error)
      end
    end

  end

  describe 'self.disable_patient_identity_by_id' do

    let(:response_message) { { 'id' => '1', 'tid' => 'test_tenant_tid', 'name' => 'test_tenant', 'tenant_enabled' => 'true',
                               'indexing_enabled' => 'true', 'gi_enabled' => 'true', 'hf_reveal_enabled' => 'true', 'patient_identity_disabled' => 'false' } }
    let(:expected_error) { Cdris::Gateway::Exceptions::UnableToDisablePatientIdentityDisabledError }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/admin/tenants/patient_identity_disable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.disable_patient_identity_by_id(1, response_message)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/admin/tenants/patient_identity_disable/1?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: '{ "error" : "UnableToDisablePatientIdentityDisabledError" }', status: ['400', 'Unable To Disable Patient Identity Disabled'])
      end

      it 'raises a tenant invalid error' do
        expect { described_class.disable_patient_identity_by_id(1, response_message) }.to raise_error(expected_error)
      end
    end

  end

end
