require './spec/spec_helper'
require './lib/neutrino/gateway/map_type'
require './lib/neutrino/gateway/requestor'
require 'fakeweb'

describe Neutrino::Gateway::MapType do

  let(:base_api) { 'base_api' }

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
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

  describe 'self.get_summary_by_type' do

    let(:expected_summary) { { 'type_of_service'  => { 'total' => 200, 'total_mapped' => 15 },
                               'kind_of_document' => { 'total' => 150, 'total_mapped' => 10 },
                               'subject_matter_domain' => { 'total' => 500, 'total_mapped' => 30 },
                               'facility' => { 'total' => 100, 'total_mapped' => 8 } } }

    it 'gets a map_type' do
      FakeWeb.register_uri(
        :get,
        'http://testhost:4242/api/v1/map_type/summary_by_type?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
        body: expected_summary.to_json)

      expect(described_class.get_summary_by_type).to eq(expected_summary)
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
      expect(Neutrino::Gateway::Requestor).to receive(:request).with(anything, { method: :post }, anything)
      described_class.create_map_type(anything)
    end

    it 'performs a request specifying the passed body' do
      expect(Neutrino::Gateway::Requestor).to receive(:request).with(anything, anything, 'foobar')
      described_class.create_map_type('foobar')
    end

    it 'performs a request against the map type URI' do
      allow(Neutrino::Gateway::Requestor).to receive(:api).and_return('api_uri')
      expect(Neutrino::Gateway::Requestor).to receive(:request).with('api_uri/map_type', anything, anything)
      described_class.create_map_type(anything)
    end

  end

  describe 'self.import_map_type_file' do

    let(:sample_mappings_file) { File.new('spec/fixtures/sample6.csv') }
    let(:sample_uploaded_file) { ActionDispatch::Http::UploadedFile.new({tempfile: sample_mappings_file, filename: 'sample6.csv', head: "Content-Disposition: form-data; name=\"fileUpload\"; filename=\"sample6.csv\"\r\nContent-Type: application/vnd.ms-excel\r\n", type: 'application/vnd.ms-excel'}) }
    let(:sample_multipart_upload) { UploadIO.new(sample_uploaded_file, sample_uploaded_file.content_type, sample_uploaded_file.original_filename) }

    it 'performs a request specifying the post_multipart method' do
      expect(Neutrino::Gateway::Requestor).to receive(:request).with(anything, { method: :post_multipart }, anything, anything, anything)
      described_class.import_map_type_file(sample_uploaded_file)
    end

    it 'performs a request specifying the passed body' do
      allow(UploadIO).to receive(:new).with(sample_uploaded_file, sample_uploaded_file.content_type, sample_uploaded_file.original_filename).and_return(sample_multipart_upload)
      expect(Neutrino::Gateway::Requestor).to receive(:request).with(anything, anything, {'fileUpload' => sample_multipart_upload}, anything, anything)
      described_class.import_map_type_file(sample_uploaded_file)
    end

    it 'performs a request against the map type import URI' do
      allow(Neutrino::Gateway::Requestor).to receive(:api).and_return('api_uri')
      expect(Neutrino::Gateway::Requestor).to receive(:request).with('api_uri/map_type/import/file', anything, anything, anything, anything)
      described_class.import_map_type_file(sample_uploaded_file)
    end

    it 'performs a request without using basic auth' do
      allow(Neutrino::Gateway::Requestor).to receive(:api).and_return('api_uri')
      expect(Neutrino::Gateway::Requestor).to receive(:request).with(anything, anything, anything, anything, anything)
      described_class.import_map_type_file(sample_uploaded_file)
    end

    it 'performs a request specifying the http timeout should be extended for this specific call' do
      allow(UploadIO).to receive(:new).with(sample_uploaded_file, sample_uploaded_file.content_type, sample_uploaded_file.original_filename).and_return(sample_multipart_upload)
      expect(Neutrino::Gateway::Requestor).to receive(:request).with(anything, anything, {'fileUpload' => sample_multipart_upload}, anything, 60 * 60)
      described_class.import_map_type_file(sample_uploaded_file)
    end

  end

end
