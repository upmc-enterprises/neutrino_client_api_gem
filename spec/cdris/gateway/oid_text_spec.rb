require './spec/spec_helper'
require './lib/cdris/gateway/oid_text'
require './lib/cdris/gateway/requestor'
require 'fakeweb'

describe Cdris::Gateway::OidText do

  let(:base_api) { 'base_api' }

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    it 'gets a oid_text' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/oid_text?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.oid_text_get.to_s)

      described_class.get().should == DataSamples.oid_text_get.to_hash
    end

    it 'gets a oid_text with group' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/oid_text/MRN?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.oid_text_get.to_s)

      described_class.get({ 'group' => 'MRN' }).should == DataSamples.oid_text_get.to_hash
    end

    it 'gets a oid_text with group and oid' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/oid_text/MRN/MRN.OID?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.oid_text_get.to_s)

      described_class.get({ 'group' => 'MRN', 'oid' => 'MRN.OID' }).should == DataSamples.oid_text_get.to_hash
    end

  end

end
