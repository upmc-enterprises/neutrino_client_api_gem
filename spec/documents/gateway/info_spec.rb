require './spec/spec_helper'
require './lib/documents/gateway/info'

describe Neutrino::Gateway::Info do

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  let(:sample_base_uri) { 'sample_base_uri' }

  describe 'self.deployments' do

    it 'returns the expected deployments' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/cdris/deployments?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.info_deployments.to_s)
      expect(described_class.deployments(OPTIONS_WITH_REMOTE_IP)).to eq(DataSamples.info_deployments.to_hash)
    end

  end

  describe 'self.current_deployment' do

    it 'returns the expected current_deployment' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/cdris/deployment/current?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.info_current_deployment.to_s)
      expect(described_class.current_deployment(OPTIONS_WITH_REMOTE_IP)).to eq(DataSamples.info_current_deployment.to_hash)
    end

    let(:expected_current_deployments_uri) { '/documents/deployment/current' }

  end

  describe 'self.configuration' do

    context 'with an implicit tenant' do
      it 'returns the expected configuration when a category is given' do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/cdris/configuration/a_category?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: DataSamples.info_configuration.to_s)
        expect(described_class.configuration('a_category', OPTIONS_WITH_REMOTE_IP)).to eq(DataSamples.info_configuration.to_hash)
      end

      it 'returns all configurations when a category is not given' do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/cdris/configuration?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .to_return(body: DataSamples.info_configurations.to_s)
        expect(described_class.configuration).to eq(DataSamples.info_configurations.to_hash)
      end

    end

    context 'with an explicit tenant' do

      let(:tenant) {{ tid: 'some_tenant'}}

      it 'returns the expected configuration when a category is given' do
        WebMock.stub_request(
            :get,
            'http://testhost:4242/cdris/configuration/a_category?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&tid=some_tenant')
            .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
            .to_return(body: DataSamples.info_configuration.to_s)
        expect(described_class.configuration('a_category', tenant.merge(OPTIONS_WITH_REMOTE_IP))).to eq(DataSamples.info_configuration.to_hash)
      end

      it 'returns all configurations when a category is not given' do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/cdris/configuration?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&tid=some_tenant')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: DataSamples.info_configurations.to_s)
        expect(described_class.configuration(nil, tenant.merge(OPTIONS_WITH_REMOTE_IP))).to eq(DataSamples.info_configurations.to_hash)
      end

    end

  end

end
