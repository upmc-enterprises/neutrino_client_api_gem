require './spec/spec_helper'
require './lib/cdris/gateway/data_quality_report'
require './lib/cdris/gateway/requestor'
require './lib/cdris/gateway/exceptions'
require 'fakeweb'

describe Cdris::Gateway::DataQualityReport do

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.create_or_update' do

    let(:path) { '/api/v1/reports/data-quality/summary/generate' }
    let(:response_message) { { 'message'=>'The system is updating the report' }  }

    before(:each) do
      FakeWeb.register_uri(
        :post,
        'http://testhost:4242/api/v1/reports/data-quality/summary/generate?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: response_message.to_json , status: ['200', 'OK'])
    end

    it 'performs a post request' do
      expect(Cdris::Gateway::Requestor).to receive(:request).with(path, { method: :post }).and_call_original
      expect(described_class.create_or_update).to eq(response_message)
    end

    context 'when the server returns a 400 error' do

      before(:each) do
        FakeWeb.register_uri(
          :post,
          'http://testhost:4242/api/v1/reports/data-quality/summary/generate?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: 'Bad Request', status: ['400', 'Bad Request'])
      end

      it 'raises a bad request error' do
        expect(Cdris::Gateway::Requestor).to receive(:request).with(path, { method: :post }).and_call_original
        expect { described_class.create_or_update }.to raise_error(Cdris::Gateway::Exceptions::BadRequestError)
      end

    end

  end
end
