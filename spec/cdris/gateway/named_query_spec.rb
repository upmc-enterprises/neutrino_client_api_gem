require './spec/spec_helper'
require './lib/cdris/gateway/named_query'
require './lib/cdris/gateway/requestor'
require 'fakeweb'

describe Cdris::Gateway::NamedQuery do

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/named_query/i_exist?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => '{}')

    it 'gets query results when an existing query name is passed' do
      described_class.get('i_exist').should == JSON.parse('{}')
    end

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/named_query/i_dont_exist?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.named_query_not_found_error.to_s)

    it 'gets a "named query not found" error when the passed query name is not know by cdris' do
      described_class.get('i_dont_exist').should == DataSamples.named_query_not_found_error.to_hash
    end

  end

  describe 'self.known_queries' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/named_query?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.named_query_list_of_queries.to_s)

    it 'gets query results when an existing query name is passed' do
      described_class.known_queries.should == DataSamples.named_query_list_of_queries.to_hash
    end

  end

end
