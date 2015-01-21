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

end