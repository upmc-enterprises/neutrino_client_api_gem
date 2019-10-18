require './spec/spec_helper'
require './lib/neutrino/gateway/uri/whitelist_factory'
require './lib/neutrino/gateway/exceptions'

describe Neutrino::Gateway::Uri::WhitelistFactory do

  describe '.build' do

    it 'raises a BadRequestError when multiple whitelists are specified' do
      expect do
        described_class.new
                        .from_whitelists_in(type_of_service_whitelist: [], subject_matter_domain_whitelist: [])
                        .build
      end.to raise_error(Neutrino::Gateway::Exceptions::BadRequestError)
    end

    context 'when params not specifying a whitelist are given' do

      let(:params_not_specifying_whitelist) { {} }

      it 'builds a Whitelist that become an empty string on to_s' do
        expect(subject.from_whitelists_in(params_not_specifying_whitelist).build.to_s).to eq('')
      end

    end

    context 'when empty values are given and the uri is built' do

      let(:empty_values) { [] }
      let(:params) { {} }

      context 'when type of service whitelist is specified' do

        before(:each) { params[:type_of_service_whitelist] = empty_values }

        it 'raises a Neutrino::Gateway::Exceptions::TypesOfServiceNotProvided' do
          expect { subject.from_whitelists_in(params).build.to_s }.to raise_error(Neutrino::Gateway::Exceptions::TypesOfServiceNotProvided)
        end

      end

      context 'when subject matter domain whitelist is specified' do

        before(:each) { params[:subject_matter_domain_whitelist] = empty_values }

        it 'raises a Neutrino::Gateway::Exceptions::SubjectMatterDomainsNotProvided' do
          expect { subject.from_whitelists_in(params).build.to_s }.to raise_error(Neutrino::Gateway::Exceptions::SubjectMatterDomainsNotProvided)
        end

      end

    end

  end

end
