require './spec/spec_helper'
require './lib/documents/gateway/data_quality_report'
require './lib/documents/gateway/requestor'
require './lib/documents/gateway/exceptions'

describe Documents::Gateway::DataQualityReport do
  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.summary' do
    let(:path) { '/api/v1/reports/data-quality/summary' }
    let(:response_message) { { 'content' => 'some data', 'message'=>'The system is updating the report' }  }

    before(:each) do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/reports/data-quality/summary?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.summary(OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do
      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/reports/data-quality/summary?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Bad Request', status: ['400', 'Bad Request'])
      end

      it 'raises a bad request error' do
        expect { described_class.summary(OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::BadRequestError)
      end
    end
  end

  describe 'self.twelve_month_volume_by_source_created_at' do
    let(:response_message) { { 'content' => 'some data', 'message'=>'The system is updating the report' }  }

    before(:each) do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/reports/data-quality/twelve_month_volume_by_source_created_at?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.twelve_month_volume_by_source_created_at(OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do
      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/reports/data-quality/twelve_month_volume_by_source_created_at?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Bad Request', status: ['400', 'Bad Request'])
      end

      it 'raises a bad request error' do
        expect { described_class.twelve_month_volume_by_source_created_at(OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::BadRequestError)
      end
    end
  end

  describe 'self.twelve_month_volume_by_created_at' do
    let(:response_message) { { 'content' => 'some data', 'message'=>'The system is updating the report' }  }

    before(:each) do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/reports/data-quality/twelve_month_volume_by_created_at?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'returns the expected result' do
      expect(described_class.twelve_month_volume_by_created_at(OPTIONS_WITH_REMOTE_IP)).to eq(response_message)
    end

    context 'when the server returns a 400 error' do
      before(:each) do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/reports/data-quality/twelve_month_volume_by_created_at?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Bad Request', status: ['400', 'Bad Request'])
      end

      it 'raises a bad request error' do
        expect { described_class.twelve_month_volume_by_created_at(OPTIONS_WITH_REMOTE_IP) }.to raise_error(Documents::Gateway::Exceptions::BadRequestError)
      end
    end
  end
end
