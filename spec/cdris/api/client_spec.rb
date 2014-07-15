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
      described_class.config.should == TestConfig.to_hash
    end

  end

  describe 'self.symbolize_keys' do

    context 'given nil' do
      let(:hash) { nil }

      it 'returns nil' do
        described_class.symbolize_keys(hash).should be_nil
      end

    end

    context 'given an empty Hash' do
      let(:hash) { {} }

      it 'returns an empty hash' do
        described_class.symbolize_keys(hash).should == {}
      end

    end

    context 'given a hash with a few strings as keys' do
      let(:hash) { { 'foo' => 5, 'bar' => [] } }

      it 'returns a hash that has the same number of keys as the passed' do
        described_class.symbolize_keys(hash).keys.count.should == hash.keys.count
      end

      it 'returns a hash where all the keys are strings' do
        described_class.symbolize_keys(hash).keys.each { |key| key.should be_an_instance_of(Symbol) }
      end

    end

  end

  describe 'self.protocol' do

    it 'returns the protocol specified in the config when a config was given' do
      described_class.protocol.should == TestConfig.protocol
    end

  end

  describe 'self.host' do

    it 'returns the host specified in the config when a config was given' do
      described_class.host.should == TestConfig.host
    end

  end

  describe 'self.port' do

    it 'returns the port specified in the config when a config was given' do
      described_class.port.should == TestConfig.port
    end

  end

  describe 'self.auth_user' do

    it 'returns the auth_user specified in the config when a config was given' do
      described_class.auth_user.should == TestConfig.auth_user
    end

  end

  describe 'self.auth_pass' do

    it 'returns the auth_pass specified in the config when a config was given' do
      described_class.auth_pass.should == TestConfig.auth_pass
    end

  end

  describe 'self.user_root' do

    it 'returns the user_root specified in the config when a config was given' do
      described_class.user_root.should == TestConfig.user_root
    end

  end

  describe 'self.user_extension' do

    it 'returns the user_extension specified in the config when a config was given' do
      described_class.user_extension.should == TestConfig.user_extension
    end

  end

  describe 'self.api_version' do

    it 'returns the api_version specified in the config when a config was given' do
      described_class.api_version.should == TestConfig.api_version
    end

    it 'returns the default api_version when a config was not given' do
      described_class.config = nil
      described_class.api_version.should == described_class::DEFAULT_API_VERSION
    end

    it 'returns the default api_version when the given config contains no api_version' do
      described_class.config = {}
      described_class.api_version.should == described_class::DEFAULT_API_VERSION
    end

  end

  describe 'self.perform_request' do

    it 'raises an error when a bogus uri is given' do
      expect { described_class.perform_request('bogus') }.to raise_error
    end

    let(:mock_http) { Object.new }
    let(:not_found_response) { Object.new }
    let(:server_error_response) { Object.new }
    let(:response_body) { 'I am the response body' }

    before(:each) do
      mock_http.stub(:body)
      Net::HTTP.stub(:start).and_yield(mock_http)
      not_found_response.stub(:code).and_return('404')

      server_error_response.stub(:code).and_return('500')
      server_error_response.stub(:body).and_return('')
    end

    it 'raises "Connection refused" when the http request throws an Errno::ECONNREFUSED' do
      mock_http.stub(:request).and_raise(Errno::ECONNREFUSED)
      expect { described_class.perform_request('bogus') }.to raise_error('Connection refused')
    end

    it 'raises "Connection refused" when the http request throws an OpenSSL::SSL::SSLError' do
      mock_http.stub(:request).and_raise(OpenSSL::SSL::SSLError)
      expect { described_class.perform_request('bogus') }.to raise_error('Connection refused')
    end

  end

  describe 'self.get_method' do

    let(:options) { {} }

    context 'when options specify no methods' do

      it 'returns Net::HTTP::Get' do
        described_class.get_method(options).should == Net::HTTP::Get
      end

    end

    context 'when options contain the :get method' do

      before(:each) { options[:method] = :get }

      it 'returns Net::HTTP::Get' do
        described_class.get_method(options).should == Net::HTTP::Get
      end

    end

    context 'when options contain the :post method' do

      before(:each) { options[:method] = :post }

      it 'returns Net::HTTP::Post' do
        described_class.get_method(options).should == Net::HTTP::Post
      end

    end

    context 'when options contain the :post_multipart method' do

      before(:each) { options[:method] = :post_multipart }

      it 'returns Net::HTTP::Post::Multipart' do
        described_class.get_method(options).should == Net::HTTP::Post::Multipart
      end

    end

    context 'when options contain the :delete method' do

      before(:each) { options[:method] = :delete }

      it 'returns Net::HTTP::Delete' do
        described_class.get_method(options).should == Net::HTTP::Delete
      end
    end

  end

end
