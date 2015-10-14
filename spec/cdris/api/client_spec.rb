require './spec/spec_helper'
require './lib/cdris/api/client'
require 'fakeweb'
require 'net/http'
require 'uri'

describe Cdris::Api::Client do

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.config' do

    it 'returns a config dictionary when one has been set' do
      expect(described_class.config).to eq(TestConfig.to_hash)
    end

  end

  describe 'self.symbolize_keys' do

    context 'given nil' do
      let(:hash) { nil }

      it 'returns nil' do
        expect(described_class.symbolize_keys(hash)).to be_nil
      end

    end

    context 'given an empty Hash' do
      let(:hash) { {} }

      it 'returns an empty hash' do
        expect(described_class.symbolize_keys(hash)).to eq({})
      end

    end

    context 'given a hash with a few strings as keys' do
      let(:hash) { { 'foo' => 5, 'bar' => [] } }

      it 'returns a hash that has the same number of keys as the passed' do
        expect(described_class.symbolize_keys(hash).keys.count).to eq(hash.keys.count)
      end

      it 'returns a hash where all the keys are strings' do
        described_class.symbolize_keys(hash).keys.each { |key| expect(key).to be_an_instance_of(Symbol) }
      end

    end

  end

  describe 'self.protocol' do

    it 'returns the protocol specified in the config when a config was given' do
      expect(described_class.protocol).to eq(TestConfig.protocol)
    end

  end

  describe 'self.host' do

    it 'returns the host specified in the config when a config was given' do
      expect(described_class.host).to eq(TestConfig.host)
    end

  end

  describe 'self.port' do

    it 'returns the port specified in the config when a config was given' do
      expect(described_class.port).to eq(TestConfig.port)
    end

  end

  describe 'self.auth_user' do

    it 'returns the auth_user specified in the config when a config was given' do
      expect(described_class.auth_user).to eq(TestConfig.auth_user)
    end

  end

  describe 'self.auth_pass' do

    it 'returns the auth_pass specified in the config when a config was given' do
      expect(described_class.auth_pass).to eq(TestConfig.auth_pass)
    end

  end

  describe 'self.user_root' do

    it 'returns the user_root specified in the config when a config was given' do
      expect(described_class.user_root).to eq(TestConfig.user_root)
    end

  end

  describe 'self.user_extension' do

    it 'returns the user_extension specified in the config when a config was given' do
      expect(described_class.user_extension).to eq(TestConfig.user_extension)
    end

  end

  describe 'self.api_version' do

    it 'returns the api_version specified in the config when a config was given' do
      expect(described_class.api_version).to eq(TestConfig.api_version)
    end

    it 'returns the default api_version when a config was not given' do
      described_class.config = nil
      expect(described_class.api_version).to eq(described_class::DEFAULT_API_VERSION)
    end

    it 'returns the default api_version when the given config contains no api_version' do
      described_class.config = {}
      expect(described_class.api_version).to eq(described_class::DEFAULT_API_VERSION)
    end

  end

  describe 'self.perform_request' do

    it 'raises an error when a bogus uri is given' do
      expect { described_class.perform_request('/bogus') }.to raise_error
    end

    let(:mock_http) { Object.new }
    let(:not_found_response) { Object.new }
    let(:server_error_response) { Object.new }
    let(:response_body) { 'I am the response body' }

    before(:each) do
      allow(mock_http).to receive(:body)
      allow(Net::HTTP).to receive(:start).and_yield(mock_http)
      allow(not_found_response).to receive(:code).and_return('404')

      allow(server_error_response).to receive(:code).and_return('500')
      allow(server_error_response).to receive(:body).and_return('')
    end

    it 'raises "Connection refused" when the http request throws an Errno::ECONNREFUSED' do
      allow(mock_http).to receive(:request).and_raise(Errno::ECONNREFUSED)
      expect { described_class.perform_request('/bogus') }.to raise_error('Connection refused')
    end

    it 'raises "Connection refused" when the http request throws an OpenSSL::SSL::SSLError' do
      allow(mock_http).to receive(:request).and_raise(OpenSSL::SSL::SSLError)
      expect { described_class.perform_request('/bogus') }.to raise_error('Connection refused')
    end

  end

  describe 'self.build_request' do

    let(:mock_http) { double }
    let(:mock_request) { Net::HTTP::Get }
    let(:mock_hmac_id) { 'fake_hmac_id' }
    let(:mock_hmac_key) { 'fake_hmac_key' }
    let(:fake_path) { 'https://goto:123/api' }
    let(:params_with_tid) { { tid: 'optional_tid' } }
    let(:empty_params) { {} }

    before(:each) do
      allow(mock_http).to receive(:body)
      allow(Net::HTTP).to receive(:start).and_yield(mock_http)
      allow(mock_http).to receive(:request)

      allow(described_class).to receive(:hmac_id).and_return(mock_hmac_id)
      allow(described_class).to receive(:hmac_key).and_return(mock_hmac_key)
    end

    context 'HMAC authentication' do
      let(:mock_tenant_id) { 'fake_tenant' }
      let(:mock_tenant_key) { 'fake_tenant_key' }

      context 'without tenant configured' do

        before(:each) do
          allow(described_class).to receive(:tenant_id).and_return(nil)
          allow(described_class).to receive(:tenant_key).and_return(nil)
        end

        it 'and request has been signed' do
          expect(ApiAuth).to receive(:sign!).with(mock_request, mock_hmac_id, mock_hmac_key)
          described_class.build_request(fake_path)
        end

        it 'request has been signed with tid specified in options' do
          expect(ApiAuth).to receive(:sign!).with(mock_request, mock_hmac_id, mock_hmac_key)
          described_class.build_request(fake_path, params_with_tid)
        end

      end

      context 'with tenant configured' do

        before(:each) do
          allow(described_class).to receive(:tenant_id).and_return(mock_tenant_id)
          allow(described_class).to receive(:tenant_key).and_return(mock_tenant_key)
        end

        it 'and request has been signed' do
          expect(ApiAuth).to receive(:sign!).with(mock_request, mock_hmac_id, anything)
          described_class.build_request(fake_path)
        end

        it 'and request has been signed with tid specified in option hash' do
          expect(ApiAuth).to receive(:sign!).with(mock_request, mock_hmac_id, mock_hmac_key)
          described_class.build_request(fake_path, params_with_tid)
        end

        context 'when basic authentication is specified on request' do

          it 'should not sign request' do
            expect(ApiAuth).to_not receive(:sign!)
            described_class.build_request(fake_path, empty_params, nil, true)
          end
        end
      end

      context 'without application configured' do

        before(:each) do
          described_class.config[:hmac_id] = nil
          described_class.config[:hmac_key] = nil
        end

        it 'should not sign request' do
          expect(ApiAuth).to_not receive(:sign!)
          described_class.build_request(fake_path)
        end
      end
    end
  end

  describe 'self.get_method' do

    let(:options) { {} }

    context 'when options specify no methods' do

      it 'returns Net::HTTP::Get' do
        expect(described_class.get_method(options)).to eq(Net::HTTP::Get)
      end

    end

    context 'when options contain the :get method' do

      before(:each) { options[:method] = :get }

      it 'returns Net::HTTP::Get' do
        expect(described_class.get_method(options)).to eq(Net::HTTP::Get)
      end

    end

    context 'when options contain the :post method' do

      before(:each) { options[:method] = :post }

      it 'returns Net::HTTP::Post' do
        expect(described_class.get_method(options)).to eq(Net::HTTP::Post)
      end

    end

    context 'when options contain the :post_multipart method' do

      before(:each) { options[:method] = :post_multipart }

      it 'returns Net::HTTP::Post::Multipart' do
        expect(described_class.get_method(options)).to eq(Net::HTTP::Post::Multipart)
      end

    end

    context 'when options contain the :delete method' do

      before(:each) { options[:method] = :delete }

      it 'returns Net::HTTP::Delete' do
        expect(described_class.get_method(options)).to eq(Net::HTTP::Delete)
      end
    end

  end

end
