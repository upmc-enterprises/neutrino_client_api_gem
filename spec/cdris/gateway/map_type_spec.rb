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

end
