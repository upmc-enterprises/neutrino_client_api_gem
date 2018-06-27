require './spec/spec_helper'
require './lib/cdris/gateway/requestor'
require './lib/cdris/gateway/exceptions'
require './lib/cdris/gateway/subsections'
require 'fakeweb'

describe Cdris::Gateway::Subsections do

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.show_subsections' do

    let(:response_message) { [{ 'id' => '1', 'root_type' => 'invalid', 'root' => 'test', 'long_desc' => 'long', 'short_desc' => 'short' }] }

    before(:each) do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/subsection?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json, status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.show_subsections).to eq(response_message.to_json)
    end

  end
end
