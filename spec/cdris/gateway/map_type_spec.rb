require './spec/spec_helper'
require './lib/cdris/gateway/map_type'
require './lib/cdris/gateway/requestor'
require 'fakeweb'

describe Cdris::Gateway::MapType do

  let(:base_api) { 'base_api' }

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  describe 'self.get' do

    let(:param_unmapped) { { unmapped: true } }

    it 'gets a map_type' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/map_type/unmapped?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: DataSamples.map_type_get.to_s)

      expect(described_class.get(param_unmapped)).to eq(DataSamples.map_type_get.to_hash)
    end

  end

  describe 'self.get_total_document_count_to_update' do

    let(:sample_document_to_update_count) { '42' }

    it 'gets a count of remaining documents' do
      FakeWeb.register_uri(
          :get,
          'http://testhost:4242/api/v1/map_type/total_count_to_update?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
          body: sample_document_to_update_count)

      expect(described_class.get_total_document_count_to_update).to eq(sample_document_to_update_count)
    end

  end

  describe 'self.create_map_type' do

    it 'performs a request specifying the post method' do
      expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, { method: :post }, anything)
      described_class.create_map_type(anything)
    end

    it 'performs a request specifying the passed body' do
      expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, anything, 'foobar')
      described_class.create_map_type('foobar')
    end

    it 'performs a request against the map type URI' do
      allow(Cdris::Gateway::Requestor).to receive(:api).and_return('api_uri')
      expect(Cdris::Gateway::Requestor).to receive(:request).with('api_uri/map_type', anything, anything)
      described_class.create_map_type(anything)
    end

  end

  describe 'self.import_map_type_file' do

    let(:sample_mappings_file) { File.new('spec/fixtures/sample6.csv') }
    let(:sample_uploaded_file) { ActionDispatch::Http::UploadedFile.new({tempfile: sample_mappings_file, filename: 'sample6.csv', head: "Content-Disposition: form-data; name=\"fileUpload\"; filename=\"sample6.csv\"\r\nContent-Type: application/vnd.ms-excel\r\n", type: 'application/vnd.ms-excel'}) }
    let(:sample_multipart_upload) { UploadIO.new(sample_uploaded_file, sample_uploaded_file.content_type, sample_uploaded_file.original_filename) }

    it 'performs a request specifying the post_multipart method' do
      expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, { method: :post_multipart }, anything, anything)
      described_class.import_map_type_file(sample_uploaded_file)
    end

    it 'performs a request specifying the passed body' do
      allow(UploadIO).to receive(:new).with(sample_uploaded_file, sample_uploaded_file.content_type, sample_uploaded_file.original_filename).and_return(sample_multipart_upload)
      expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, anything, {'fileUpload' => sample_multipart_upload}, anything)
      described_class.import_map_type_file(sample_uploaded_file)
    end

    it 'performs a request against the map type import URI' do
      allow(Cdris::Gateway::Requestor).to receive(:api).and_return('api_uri')
      expect(Cdris::Gateway::Requestor).to receive(:request).with('api_uri/map_type/import/file', anything, anything, anything)
      described_class.import_map_type_file(sample_uploaded_file)
    end

    it 'performs a request using basic auth' do
      allow(Cdris::Gateway::Requestor).to receive(:api).and_return('api_uri')
      expect(Cdris::Gateway::Requestor).to receive(:request).with(anything, anything, anything, true)
      described_class.import_map_type_file(sample_uploaded_file)
    end

  end

end
