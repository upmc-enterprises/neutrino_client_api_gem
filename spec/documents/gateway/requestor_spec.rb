require './spec/spec_helper'
require './lib/documents/api/client'
require './lib/documents/gateway/requestor'
require './lib/documents/gateway/exceptions'

describe Neutrino::Gateway::Requestor do

  let(:expected_api_version) { 'expected_api_version' }

  before(:each) do
    allow(Neutrino::Api::Client).to receive(:api_version).and_return(expected_api_version)
  end

  describe '.request' do
    subject { described_class.request(*params) }

    let(:successful_response) { double('Response', code: '200').as_null_object }

    context 'when given a path' do
      let(:params) { [path] }
      let(:path) { double('Path') }

      it 'performs a request using that path and some defaults' do
        expect(Neutrino::Api::Client).
          to receive(:perform_request).
          with(path, {}, nil, false, nil).
          and_return(successful_response)
        subject
      end

      context 'and given the other parameters' do
        before(:each) { params.concat([double, double, double, double]) }

        it 'performs a request using the passed params, in the same order' do
          expect(Neutrino::Api::Client).
            to receive(:perform_request).
            with(*params).
            and_return(successful_response)
          subject
        end
      end

      [
        rand(199)+301, rand(199)+301, rand(199)+301, rand(199)+301, rand(199)+301
      ].each do |code|
        context "and the request produces a response with a non-200 family, non-500 code of #{code}" do
          before(:each) do
            allow(Neutrino::Api::Client).
              to receive(:perform_request).
              and_return(double('Response', code: code.to_s, body: '{ "some": "body" }'))
          end

          describe '#to_hash' do
            specify { expect { subject.to_hash }.to raise_error(Neutrino::Gateway::Exceptions::FailedRequestError) }
          end

          describe '#data_and_type' do
            specify { expect { subject.data_and_type }.to raise_error(Neutrino::Gateway::Exceptions::FailedRequestError) }
          end
        end

        context 'and the request produces a response with code 500' do
          before(:each) do
            allow(Neutrino::Api::Client).
              to receive(:perform_request).
              and_return(double('Response', code: '500', body: '{ "error": "Internal Server Error" }'))
          end

          specify { expect { subject }.to raise_error(Neutrino::Gateway::Exceptions::InternalServerError) }
        end
      end
    end
  end

  describe 'self.api' do

    let(:debug_uri_matcher) { %r{/debug/true$} }

    context 'when no options are given' do

      let(:resultant_uri) { described_class.api }

      it 'does not include the debug component in the resultant URI' do
        expect(resultant_uri).not_to match(debug_uri_matcher)
      end

    end

    context 'when options do not contain a debug' do

      let(:options) { {} }

      it 'does not include the debug component in the resultant URI' do
        expect(described_class.api(options)).not_to match(debug_uri_matcher)
      end

    end

    context 'when options contain a debug' do

      let(:options) { { debug: true } }

      it 'includes the debug URI component in the resultant URI' do
        expect(described_class.api(options)).to match(debug_uri_matcher)
      end

    end

  end

end
