require './spec/spec_helper'
require './lib/cdris/gateway/application_accounts'
require './lib/cdris/gateway/requestor'
require 'fakeweb'

describe Cdris::Gateway::ApplicationAccounts do

  let(:base_api) { 'base_api' }

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    it 'gets application accounts' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/admin/application_accounts?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.application_accounts.to_s)

      described_class.get.should == DataSamples.application_accounts.to_hash
    end

  end

end