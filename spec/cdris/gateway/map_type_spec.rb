require './spec/spec_helper'
require './lib/cdris/gateway/map_type'
require './lib/cdris/gateway/requestor'
require 'fakeweb'

describe Cdris::Gateway::MapType do

  let(:base_api) { 'base_api' }

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    let(:param_unmapped) { { :unmapped => true } }

    it 'gets a map_type' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/map_type/unmapped?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        :body => DataSamples.map_type_get.to_s)

      described_class.get(param_unmapped).should == DataSamples.map_type_get.to_hash
    end

  end

  describe 'self.create_map_type' do

    it 'performs a request specifying the post method' do
      expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, { method: :post }, anything)
      described_class.create_map_type(anything)
    end

    it 'performs a request specifying the passed body' do
      expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, anything, 'foobar')
      described_class.create_map_type('foobar')
    end

    it 'performs a request against the map type URI' do
      Cdris::Gateway::Requestor.stub(:api).and_return('api_uri')
      expect(Cdris::Gateway::Requestor).to receive(:request).with('api_uri/map_type', anything, anything)
      described_class.create_map_type(anything)
    end

  end

end
