require './spec/spec_helper'
require './lib/neutrino/gateway/named_query'
require './lib/neutrino/gateway/requestor'

describe Neutrino::Gateway::NamedQuery do

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    it 'gets query results when an existing query name is passed' do
      WebMock.stub_request(
        :get,
        "http://testhost:4242/api/v1/named_query/i_exist?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
        .to_return(body: '{}')
      expect(described_class.get('i_exist')).to eq(JSON.parse('{}'))
    end

    it 'gets a "named query not found" error when the passed query name is not know by cdris' do
      WebMock.stub_request(
        :get,
        "http://testhost:4242/api/v1/named_query/i_dont_exist?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
        .to_return(body: DataSamples.named_query_not_found_error.to_s)
      expect(described_class.get('i_dont_exist')).to eq(DataSamples.named_query_not_found_error.to_hash)
    end

  end

  describe 'self.known_queries' do

    it 'gets query results when an existing query name is passed' do
      WebMock.stub_request(
        :get,
        "http://testhost:4242/api/v1/named_query?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
        .to_return(body: DataSamples.named_query_list_of_queries.to_s)
      expect(described_class.known_queries).to eq(DataSamples.named_query_list_of_queries.to_hash)
    end

  end

end
