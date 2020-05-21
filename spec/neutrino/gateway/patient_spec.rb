require './spec/spec_helper'
require './lib/neutrino/gateway/patient'
require './lib/neutrino/api/client'
require './lib/neutrino/gateway/requestor'
require './lib/neutrino/gateway/uri/whitelist_factory'
require './lib/neutrino/gateway/exceptions'

describe Neutrino::Gateway::Patient do

  before(:each) do
    Neutrino::Api::Client.config = TestConfig.to_hash
  end

  let(:root) { 'srcsys' }
  let(:extension) { '1234' }
  let(:params_root_and_extension) { { root: root, extension: extension } }
  let(:invalid_user_params_root_and_extension) { { root: 'fdsaf', extension: 'gsaewags' } }
  let(:user_root_and_extension) { { user: { root: 'foobar', extension: 'spameggs' } } }
  let(:set_in_error_exception) { Neutrino::Gateway::Exceptions::PatientIdentitySetInError }
  let(:invalid_tenant_operation) { Neutrino::Gateway::Exceptions::InvalidTenantOperation }
  let(:mock_response) { double('Mock Response', code: 403, body: {}) }

  shared_examples 'the_patient_identity_set_is_in_error' do

    it 'raises a patient set in error exception' do
      allow(Neutrino::Api::Client).to receive(:perform_request).and_return(mock_response)
      expect {
        described_class.send(patient_method, params_root_and_extension)
      }.to raise_error(set_in_error_exception)
    end

  end

  shared_examples 'the_operation_is_forbidden_to_the_tenant' do

    it 'raises an invalid tenant operation exception' do
      allow(Neutrino::Api::Client).to receive(:perform_request).and_return(mock_response)
      expect {
        described_class.send(patient_method, params_root_and_extension)
      }.to raise_error(invalid_tenant_operation)
    end

  end

  describe 'self.demographics' do

    it 'performs a request returning valid demographics' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/srcsys/1234/demographics?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.patient_demographics.to_s)
      expect(described_class.demographics(
        params_root_and_extension,
        user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(DataSamples.patient_demographics.to_hash)
    end

    it 'raises a PatientNotFoundError when it it receives a 404 after requesting patient demographics' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/srcsys/4321/demographics?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(status: ['404', 'OK'])
      expect do
        described_class.demographics({ root: 'srcsys', extension: '4321' }, OPTIONS_WITH_REMOTE_IP)
      end.to raise_error(Neutrino::Gateway::Exceptions::PatientNotFoundError)
    end

  end

  describe 'self.identities' do

    let(:patient_method) { :identities }

    it_behaves_like 'the_patient_identity_set_is_in_error'

    it 'performs a request returning valid identities' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/srcsys/1234/identities?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.patient_identities.to_s)
      expect(described_class.identities(
        params_root_and_extension,
        user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(DataSamples.patient_identities.to_hash)
    end

  end

  describe 'self.identities_in_error' do

    it 'performs a request returning identities in error' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/identities_in_error?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.patient_identities_in_error.to_s)
      expect(described_class.identities_in_error(OPTIONS_WITH_REMOTE_IP)).to eq(DataSamples.patient_identities_in_error.to_hash)
    end

  end

  describe '.active_identities' do
    subject { described_class.active_identities(params, OPTIONS_WITH_REMOTE_IP) }

    let(:patient_method) { :active_identities }

    it_behaves_like 'the_patient_identity_set_is_in_error'

    context 'when a patient exists with root: root42 and extension: ext42' do
      [
        { root: 'non-exist', extension: 'non-exist' },
        { root: 'root42', extension: 'non-exist' },
        { root: 'non-exist', extension: 'ext42' },
      ].each do |root_and_ext|
        context "when querying for #{root_and_ext.inspect}" do
          let(:params) { root_and_ext }

          before(:each) do
            WebMock.stub_request(
              :get,
              "http://testhost:4242/api/v1/patient/#{root_and_ext[:root]}/#{root_and_ext[:extension]}/active_identities?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
              .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
              .to_return(status: 404)
          end

          specify { expect { subject }.to raise_error(Neutrino::Gateway::Exceptions::PatientNotFoundError) }
        end
      end

      context 'and querying for root: root42, extension: ext42' do
        let(:params) { { root: 'root42', extension: 'ext42' } }

        it 'is the identities returned from NEUTRINO as a hash' do
          WebMock.stub_request(
            :get,
            'http://testhost:4242/api/v1/patient/root42/ext42/active_identities?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
            .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
            .to_return(body: DataSamples.patient_identities.to_s)
          expect(subject).to eq(DataSamples.patient_identities.to_hash)
        end
      end
    end
  end

  describe 'self.set_in_error' do

    context 'when identity is not in error' do

      before(:each) do
        WebMock.stub_request(:post, "http://testhost:4242/api/v1/patient/#{root}/#{extension}/set_in_error?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: '{ "data_status": true }')
      end

      it 'performs a request returning true' do
        expect(described_class.set_in_error(params_root_and_extension,
                                     user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(true)
      end
    end

    context 'when identity is in error' do

      before(:each) do
        WebMock.stub_request(:post, "http://testhost:4242/api/v1/patient/#{root}/#{extension}/set_in_error?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: '{ "data_status": false }')
      end

      it 'performs a request returning false' do
        expect(described_class.set_in_error(params_root_and_extension,
                                     user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(false)
      end
    end

    context 'when patient does not exist' do

      before(:each) do
        WebMock.stub_request(:post, "http://testhost:4242/api/v1/patient/#{root}/#{extension}/set_in_error?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Patient not found.', status: ['404', 'OK'])
      end

      it 'raises a PatientNotFoundError when it receives a 404 error' do
        expect do
          described_class.set_in_error(params_root_and_extension, user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))
        end.to raise_error(Neutrino::Gateway::Exceptions::PatientNotFoundError)
      end
    end
  end

  describe 'self.self_healing' do

    let(:success_message) { {"message" => "Self-healing successful"} }

    context 'when self healing is successful' do

      before(:each) do
        WebMock.stub_request(:post, "http://testhost:4242/api/v1/patient/#{root}/#{extension}/self_healing?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: '{ "message": "Self-healing successful" }')
      end

      it 'performs a request returning a success message' do
        expect(described_class.self_healing(params_root_and_extension,
                                     user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(success_message['message'])
      end
    end

    context 'when a tenant is not authorized to invoke self healing' do

      before(:each) do
        WebMock.stub_request(:post, "http://testhost:4242/api/v1/patient/#{root}/#{extension}/self_healing?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Operation not permitted for tenant.', status: ['403', 'OK'])
      end

      it 'raises a InvalidTenantOperation error when it receives a 403 error' do
        expect do
          described_class.self_healing(params_root_and_extension, user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))
        end.to raise_error(Neutrino::Gateway::Exceptions::InvalidTenantOperation)
      end
    end

    context 'when patient does not exist in the initiate empi service' do

      before(:each) do
        WebMock.stub_request(:post, "http://testhost:4242/api/v1/patient/#{root}/#{extension}/self_healing?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar")
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: 'Patient not found.', status: ['404', 'OK'])
      end

      it 'raises a PatientNotFoundError when it receives a 404 error' do
        expect do
          described_class.self_healing(params_root_and_extension, user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))
        end.to raise_error(Neutrino::Gateway::Exceptions::PatientNotFoundError)
      end
    end
  end

  describe 'self.valid?' do

    it 'performs a request returning true given a valid user' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/srcsys/1234/validate?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: '{"valid": true}')
      expect(described_class.valid?(
        params_root_and_extension,
        user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(true)
    end

    it 'performs a request returning false given an invalid user' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/fdsaf/gsaewags/validate?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: '{"valid": false}')
      expect(described_class.valid?(
        invalid_user_params_root_and_extension,
        user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(false)
    end

  end

  describe 'self.delete' do
    before(:each) do
      WebMock.stub_request(
          :delete,
          'http://testhost:4242/api/v1/patient/srcsys/1234/delete?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: '{"data_status": "success"}', status: 200)

      WebMock.stub_request(
          :delete,
          'http://testhost:4242/api/v1/patient/fdsaf/gsaewags/delete?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(status: 500)
    end

    it 'performs a request returning 200 - the identity in error was deleted' do
      expect(described_class.delete(params_root_and_extension, user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq('success')
    end

    it 'performs a request returning 403 - requesting application or tenant is not authorized to perform lookup with Patient Identity' do
      allow(Neutrino::Api::Client).to receive(:perform_request).and_return( double('Mock Response', code: 403, body: { message: 'Application is not authorized to perform lookup with Patient Identity' }))
      expect{ described_class.delete(invalid_user_params_root_and_extension, user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP)) }.to raise_error(Neutrino::Gateway::Exceptions::InvalidTenantOperation)
    end

    it 'performs a request returning 404 - requested identity does not exist in the system' do
      allow(Neutrino::Api::Client).to receive(:perform_request).and_return( double('Mock Response', code: 404, body: {}))
      expect{ described_class.delete(invalid_user_params_root_and_extension, user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP)) }.to raise_error(Neutrino::Gateway::Exceptions::PatientNotFoundError)
    end

    it 'performs a request returning 409 - requested identity is not "in error"' do
      allow(Neutrino::Api::Client).to receive(:perform_request).and_return(double('Mock Response', code: '409', body: '{ "error": "Patient Identity is not in Error" }' ))
      expect{ described_class.delete(invalid_user_params_root_and_extension, user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP)) }.to raise_error(Neutrino::Gateway::Exceptions::PatientIdentityNotInError)
    end

    it 'performs a request returning 409 - requested identity has documents' do
      allow(Neutrino::Api::Client).to receive(:perform_request).and_return(double('Mock Response', code: '409', body: '{ "error": "Patient Identity has documents" }'))
      expect{ described_class.delete(invalid_user_params_root_and_extension, user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP)) }.to raise_error(Neutrino::Gateway::Exceptions::PatientIdentityHasDocumentsError)
    end

    it 'performs a request returning 500 - an unknown error occurred' do
      expect{ described_class.delete(invalid_user_params_root_and_extension, user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP)) }.to raise_error(Neutrino::Gateway::Exceptions::InternalServerError)
    end

  end

  describe 'self.patient_document_search' do

    let(:patient_method) { :patient_document_search }
    let(:params) { {} }

    it 'performs a request returning valid patient documents' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/srcsys/1234/patient_documents/search?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.patient_patient_document_search.to_s)
      expect(described_class.patient_document_search(
        params_root_and_extension,
        user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(DataSamples.patient_patient_document_search.to_hash)
    end

    context 'when root and extension are specified in params' do

      let(:root) { 'some_root' }
      let(:extension) { 'some_extension' }

      before(:each) do
        params[:root] = root
        params[:extension] = extension
        allow(Neutrino::Gateway::Requestor).to receive(:request).and_return(double.as_null_object)
      end

      context 'and current is specified in params' do

        before(:each) { params[:current] = true }

        it 'contains the current uri component' do
          expect(Neutrino::Gateway::Requestor).to receive(:request).with(/\/current/, anything)
          described_class.patient_documents(params)
        end

      end

    end

  end

  describe 'self.patient_documents_literal_search' do

    let(:patient_method) { :patient_document_literal_search }
    let(:params) { {} }
    let(:returned_ids) { [{"id" => '111'}, {"id" =>'222'}] }

    it 'performs a request returning valid patient documents' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/srcsys/1234/patient_documents/search?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar&literal=test')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: [{id: '111'}, {id:'222'}].to_json)
      expect(described_class.patient_documents_literal_search(
        params_root_and_extension,
        user_root_and_extension.merge({literal: 'test'}).merge(OPTIONS_WITH_REMOTE_IP))).to eq(returned_ids)
    end

    context 'when root and extension are specified in params' do

      let(:root) { 'some_root' }
      let(:extension) { 'some_extension' }

      before(:each) do
        params[:root] = root
        params[:extension] = extension
        allow(Neutrino::Gateway::Requestor).to receive(:request).and_return(double.as_null_object)
      end

    end

  end

  describe 'self.patient_hl7_document_ids' do
    let(:ids) { [1, 4, 7] }

    it 'requests and returns the expected document ids' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/foo/bar/ids/hl7?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: [1, 4, 7].to_json)
      expect(described_class.patient_hl7_document_ids({ root: 'foo', extension: 'bar' }, OPTIONS_WITH_REMOTE_IP)).to eq(ids)
    end

  end

  describe 'self.patient_document_ids' do

    context 'Without precedence' do
      let(:ids) { [1, 2, 4, 8] }

      it 'requests and returns the expected document ids' do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/patient/foo/bar/ids?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: [1, 2, 4, 8].to_json)
        expect(described_class.patient_document_ids({ root: 'foo', extension: 'bar' }, OPTIONS_WITH_REMOTE_IP)).to eq(ids)
      end

    end

    context 'With precedence' do
      let(:ids) { [1, 2, 3, 5, 8] }

      it 'requests and returns the expected document ids' do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/patient/foo/bar/ids/primary?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(body: [1, 2, 3, 5, 8].to_json)
        expect(described_class.patient_document_ids({ root: 'foo', extension: 'bar', precedence: 'primary' }, OPTIONS_WITH_REMOTE_IP)).to eq(ids)
      end
    end

  end

  describe 'self.patient_document_bounds' do
    let(:patient_method) { :patient_document_bounds }

    it 'performs a request returning valid document bounds' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/srcsys/1234/patient_document_bounds?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.patient_patient_document_bounds.to_s)
      expect(described_class.patient_document_bounds(
        params_root_and_extension,
        user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(DataSamples.patient_patient_document_bounds.to_hash)
    end

    context 'When a tenant attempts to search for documents for a patient using an invalid oid' do

      it_behaves_like 'the_operation_is_forbidden_to_the_tenant'

    end

 end

  describe 'self.subject_matter_domains' do

    it 'performs a request returning valid subject matter domains' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/srcsys/1234/patient_documents/subject_matter_domain_extension?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.patient_subject_matter_domains.to_s)
      expect(described_class.subject_matter_domains(
        params_root_and_extension,
        user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(DataSamples.patient_subject_matter_domains.to_hash)
    end

  end

  describe 'self.types_of_service' do

    it 'performs a request returning valid types of service' do
      WebMock.stub_request(
        :get,
        'http://testhost:4242/api/v1/patient/srcsys/1234/patient_documents/type_of_service_extension?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
        .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
        .to_return(body: DataSamples.patient_types_of_service.to_s)
      expect(described_class.types_of_service(
        params_root_and_extension,
        user_root_and_extension.merge(OPTIONS_WITH_REMOTE_IP))).to eq(DataSamples.patient_types_of_service.to_hash)
    end

  end

  describe 'self.patient_documents' do

    let(:date_to) { '2014-01-01T01:01:01Z' }
    let(:date_from) { '2013-01-01T01:01:01Z' }
    let(:patient_method) { :patient_documents }

    it 'raises a TimeWindowError if it is given a date range whose starting date is after the ending date' do
      allow(described_class).to receive(:base_uri).and_return('/fooey')
      expect { described_class.patient_documents(date_to: date_from, date_from: date_to) }.to raise_error(Neutrino::Gateway::Exceptions::TimeWindowError)
    end

    it 'raises a BadRequestError if more than one whitelist is specified' do
      expect { described_class.patient_documents(type_of_service_whitelist: [], with_ejection_fractions: true) }.to raise_error(Neutrino::Gateway::Exceptions::BadRequestError)
    end

    context 'when requesting a patient who does not exist' do
      let(:root) { 'somesys' }
      let(:extension) { '12345' }

      it 'raises a PatientNotFoundError' do
        WebMock.stub_request(
          :get,
          'http://testhost:4242/api/v1/patient/somesys/12345/patient_documents?user%5Bextension%5D=spameggs&user%5Broot%5D=foobar')
          .with(headers: { 'X-Forwarded-For' => REMOTE_IP })
          .to_return(status: 404)
        expect { described_class.patient_documents({ root: root, extension: extension }, OPTIONS_WITH_REMOTE_IP) }.to raise_error(Neutrino::Gateway::Exceptions::PatientNotFoundError)
      end

    end

    context 'When a tenant attempts to search for documents for a patient using an invalid oid' do

      it_behaves_like 'the_operation_is_forbidden_to_the_tenant'

    end

  end

  describe 'self.request' do
    let(:unauthorized_response) { double('Response', code: '403',
                                         body: { error: 'Application is not authorized to perform lookup with Patient Identity' }.to_json) }
    let(:unauthorized_error) { Neutrino::Gateway::Exceptions::PatientIdentityGatewayNotAuthorizedError }

    it 'raises an patient identity unauthorized error if request is unauthorized' do
      expect {
        allow(Neutrino::Api::Client).to receive(:perform_request).and_return(unauthorized_response)
        described_class.request('/some/where')
      }.to raise_error(unauthorized_error)
    end
  end

  describe 'self.base_uri' do

    context 'when id, root and extension are not given' do

      let(:params) { {} }

      it 'raises a BadRequestError' do
        expect { described_class.base_uri(params) }.to raise_error(Neutrino::Gateway::Exceptions::BadRequestError)
      end

    end

    context 'when root and extension are given' do

      let(:root) { 'some_root' }
      let(:extension) { 'some_extension' }
      let(:params) { { root: root, extension: extension } }

      it 'builds a URI containing the root and extension URI components' do
        expect(described_class.base_uri(params)).to match(%r{/#{root}/#{extension}})
      end

      context 'when the root and extension contain special characters' do
        let(:root) { 'some_root/\;:&-_$@' }
        let(:extension) { 'some_extension/\;:&-_$@' }

        it 'builds a URI containing the root and extension URI components' do
          expect(described_class.base_uri(params)).to include("/#{URI.escape(root)}/#{URI.escape(extension)}")
        end

      end

    end

  end

end
