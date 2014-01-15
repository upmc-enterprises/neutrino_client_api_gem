require './spec/spec_helper'
require './lib/cdris/api/client'
require './lib/cdris/gateway/requestor'

describe Cdris::Gateway::Requestor do

  let(:expected_api_version) { 'expected_api_version' }

  before(:each) do
    Cdris::Api::Client.stub(:api_version).and_return(expected_api_version)
  end

  describe 'self.request' do

    let(:path) { "/foo/to/the/bar" }
    let(:options) { { :blah => "halb", :racecar => "racecar" } }
    let(:body) { "snatchers" }
    let(:basic_auth) { true }
    
    it 'performs a request using the api client' do
      Cdris::Gateway::Responses::ResponseHandler.any_instance.stub(:if_500_raise)
      Cdris::Api::Client.should_receive(:perform_request).with(path, options, body, basic_auth)
      described_class.request(path, options, body, basic_auth)
    end

  end

end
