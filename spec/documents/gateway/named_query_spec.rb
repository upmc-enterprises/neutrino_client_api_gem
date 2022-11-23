require './spec/spec_helper'
require './lib/documents/gateway/named_query'
require './lib/documents/gateway/requestor'

describe Documents::Gateway::NamedQuery do

  before(:each) do
    Documents::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    it 'gets query results when an existing query name is passed' do
      WebMock.stub_request(
        :get,
        "http://testhost:4242/api/v1/named_query/i_exist?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: '{}')
      expect(described_class.get('i_exist', OPTIONS_WITH_REMOTE_IP)).to eq(JSON.parse('{}'))
    end

    it 'gets a "named query not found" error when the passed query name is not know by Documents Service' do
      WebMock.stub_request(
        :get,
        "http://testhost:4242/api/v1/named_query/i_dont_exist?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.named_query_not_found_error.to_s)
      expect(described_class.get('i_dont_exist', OPTIONS_WITH_REMOTE_IP)).to eq(DataSamples.named_query_not_found_error.to_hash)
    end

  end

  describe 'self.known_queries' do

    it 'gets query results when an existing query name is passed' do
      WebMock.stub_request(
        :get,
        "http://testhost:4242/api/v1/named_query?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.named_query_list_of_queries.to_s)
      expect(described_class.known_queries(OPTIONS_WITH_REMOTE_IP)).to eq(DataSamples.named_query_list_of_queries.to_hash)
    end

  end

end
