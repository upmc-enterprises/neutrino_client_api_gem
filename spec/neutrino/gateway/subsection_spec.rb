require './spec/spec_helper'
require './lib/neutrino/gateway/requestor'
require './lib/neutrino/gateway/exceptions'
require './lib/neutrino/gateway/subsections'
require 'fakeweb'

describe Neutrino::Gateway::Subsections do

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
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
