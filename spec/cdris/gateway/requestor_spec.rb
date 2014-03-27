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

  describe 'self.api' do

    let(:debug_uri_matcher) { /\/debug\/true$/ }

    context 'when no options are given' do

      let(:resultant_uri) { described_class.api }

      it 'does not include the debug component in the resultant URI' do
        resultant_uri.should_not match(debug_uri_matcher)
      end

    end

    context 'when options do not contain a debug' do

      let(:options) { {} }

      it 'does not include the debug component in the resultant URI' do
        described_class.api(options).should_not match(debug_uri_matcher)
      end

    end

    context 'when options contain a debug' do

      let(:options) { { debug: true } }

      it 'includes the debug URI component in the resultant URI' do
        described_class.api(options).should match(debug_uri_matcher)
      end

    end

  end

end
