require './spec/spec_helper'
require './lib/cdris/gateway/patient'
require './lib/cdris/api/client'
require './lib/cdris/gateway/requestor'
require './lib/cdris/gateway/uri/whitelist_factory'
require './lib/cdris/gateway/exceptions'
require 'fakeweb'

describe Cdris::Gateway::Patient do

  before(:each) do
    Cdris::Api::Client.config = TestConfig.to_hash
  end

  let(:root) { 'srcsys' }
  let(:extension) { '1234' }
  let(:params_root_and_extension) { { :root => root, :extension => extension } }
  let(:invalid_user_params_root_and_extension) { { :root => 'fdsaf', :extension => 'gsaewags' } }
  let(:user_root_and_extension) { { :user => { :root => 'foobar', :extension => 'spameggs' } } }

  describe 'self.demographics' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/srcsys/1234/demographics?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_demographics.to_s)

    it 'performs a request returning valid demographics' do
      described_class.demographics(
        params_root_and_extension,
      user_root_and_extension).should == DataSamples.patient_demographics.to_hash
    end

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/srcsys/4321/demographics?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :status => ['404', 'OK'])

    it 'raises a PatientNotFoundError when it it receives a 404 after requesting patient demographics' do
      expect {
        described_class.demographics({:root => 'srcsys', :extension => '4321'})
      }.to raise_error(Cdris::Gateway::Exceptions::PatientNotFoundError)
    end

  end

  describe 'self.identities' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/srcsys/1234/identities?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_identities.to_s)

    it 'performs a request returning valid identities' do
      described_class.identities(
        params_root_and_extension,
      user_root_and_extension).should == DataSamples.patient_identities.to_hash
    end

  end

  describe 'self.valid?' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/srcsys/1234/validate?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => '{"valid": true}')

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/fdsaf/gsaewags/validate?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => '{"valid": false}')

    it 'performs a request returning true given a valid user' do
      described_class.valid?(
        params_root_and_extension,
      user_root_and_extension).should == true
    end

    it 'performs a request returning false given an invalid user' do
      described_class.valid?(
        invalid_user_params_root_and_extension,
      user_root_and_extension).should == false
    end

  end

  describe 'self.patient_document_search' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/srcsys/1234/patient_documents/search?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_patient_document_search.to_s)

    it 'performs a request returning valid patient documents' do
      described_class.patient_document_search(
        params_root_and_extension,
      user_root_and_extension).should == DataSamples.patient_patient_document_search.to_hash
    end

  end

  describe 'self.patient_document_bounds' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/srcsys/1234/patient_document_bounds?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_patient_document_bounds.to_s)

    it 'performs a request returning valid document bounds' do
      described_class.patient_document_bounds(
        params_root_and_extension,
      user_root_and_extension).should == DataSamples.patient_patient_document_bounds.to_hash
    end

  end

  describe 'self.subject_matter_domains' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/srcsys/1234/patient_documents/subject_matter_domain_extension?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_subject_matter_domains.to_s)

    it 'performs a request returning valid subject matter domains' do
      described_class.subject_matter_domains(
        params_root_and_extension,
      user_root_and_extension).should == DataSamples.patient_subject_matter_domains.to_hash
    end

  end

  describe 'self.types_of_service' do

    FakeWeb.register_uri(
      :get,
      'http://testhost:4242/api/v1/patient/srcsys/1234/patient_documents/type_of_service_extension?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar',
      :body => DataSamples.patient_types_of_service.to_s)

    it 'performs a request returning valid types of service' do
      described_class.types_of_service(
        params_root_and_extension,
      user_root_and_extension).should == DataSamples.patient_types_of_service.to_hash
    end

  end

  describe 'self.patient_documents' do

    let(:date_to) { '2014-01-01T01:01:01Z' }
    let(:date_from) { '2013-01-01T01:01:01Z' }
    
    it 'raises a TimeWindowError if it is given a date range whose starting date is after the ending date' do
      described_class.stub(:base_uri).and_return('/fooey')
      expect {described_class.patient_documents({ :date_to => date_from, :date_from => date_to })}.to raise_error(Cdris::Gateway::Exceptions::TimeWindowError)
    end

    it 'raises a BadRequestError if more than one whitelist is specified' do
      expect {described_class.patient_documents({ :type_of_service_whitelist => [], :with_ejection_fractions => true })}.to raise_error(Cdris::Gateway::Exceptions::BadRequestError)
    end

  end

end
