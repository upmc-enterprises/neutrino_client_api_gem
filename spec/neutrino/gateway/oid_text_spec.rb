require './spec/spec_helper'
require './lib/neutrino/gateway/oid_text'
require './lib/neutrino/gateway/requestor'

describe Neutrino::Gateway::OidText do

  let(:base_api) { 'base_api' }

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    it 'gets a oid_text' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/oid_text?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .to_return(body: DataSamples.oid_text_get.to_s)

      expect(described_class.get()).to eq(DataSamples.oid_text_get.to_hash)
    end

    it 'gets a oid_text with group' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/oid_text/MRN?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .to_return(body: DataSamples.oid_text_get.to_s)

      expect(described_class.get({ 'group' => 'MRN' })).to eq(DataSamples.oid_text_get.to_hash)
    end

    it 'gets a oid_text with group and oid' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/oid_text/MRN/MRN.OID?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .to_return(body: DataSamples.oid_text_get.to_s)

      expect(described_class.get({ 'group' => 'MRN', 'oid' => 'MRN.OID' })).to eq(DataSamples.oid_text_get.to_hash)
    end

  end

end
