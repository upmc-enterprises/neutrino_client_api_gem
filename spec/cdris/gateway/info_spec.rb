require './spec/spec_helper'
require './lib/cdris/gateway/info'
require 'fakeweb'

describe Cdris::Gateway::Info do

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  let(:sample_base_uri) { 'sample_base_uri' }

  describe 'self.deployments' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/cdris/deployments?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.info_deployments.to_s)

    it 'returns the expected deployments' do
      expect(described_class.deployments).to eq(DataSamples.info_deployments.to_hash)
    end

  end

  describe 'self.current_deployment' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/cdris/deployment/current?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      body: DataSamples.info_current_deployment.to_s)

    it 'returns the expected current_deployment' do
      expect(described_class.current_deployment).to eq(DataSamples.info_current_deployment.to_hash)
    end

    let(:expected_current_deployments_uri) { '/cdris/deployment/current' }

  end

  describe 'self.configuration' do

    context 'with an implicit tenant' do

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/cdris/configuration/a_category?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.info_configuration.to_s)

      it 'returns the expected configuration when a category is given' do
        expect(described_class.configuration('a_category')).to eq(DataSamples.info_configuration.to_hash)
      end

      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/cdris/configuration?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.info_configurations.to_s)

      it 'returns all configurations when a category is not given' do
        expect(described_class.configuration).to eq(DataSamples.info_configurations.to_hash)
      end

    end

    context 'with an explicit tenant' do

      let(:tenant) {{ tid: 'some_tenant'}}

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/cdris/configuration/a_category?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&tid=some_tenant',
          body: DataSamples.info_configuration.to_s)

      it 'returns the expected configuration when a category is given' do
        expect(described_class.configuration('a_category', tenant)).to eq(DataSamples.info_configuration.to_hash)
      end

      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/cdris/configuration?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&tid=some_tenant',
          body: DataSamples.info_configurations.to_s)

      it 'returns all configurations when a category is not given' do
        expect(described_class.configuration(nil, tenant)).to eq(DataSamples.info_configurations.to_hash)
      end

    end

  end

end
