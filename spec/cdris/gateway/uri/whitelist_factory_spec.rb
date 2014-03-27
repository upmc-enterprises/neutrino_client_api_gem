require './spec/spec_helper'
require './lib/cdris/gateway/uri/whitelist_factory'
require './lib/cdris/gateway/exceptions'

describe Cdris::Gateway::Uri::WhitelistFactory do

  describe '.build' do

    it 'raises a BadRequestError when multiple whitelists are specified' do
      expect {
        described_class.new
                        .from_whitelists_in({ :type_of_service_whitelist => [], :with_ejection_fractions => true })
                        .build
      }.to raise_error(Cdris::Gateway::Exceptions::BadRequestError)
    end

    context 'when params not specifying a whitelist are given' do

      let(:params_not_specifying_whitelist) { {} }

      it 'builds a Whitelist that become an empty string on to_s' do
        subject.from_whitelists_in(params_not_specifying_whitelist).build.to_s.should == ''
      end

    end

    context 'when ejection fractions are included' do

      before(:each) do
        subject.from_whitelists_in({ with_ejection_fractions: true })
      end

      it 'builds a whitelist that builds a uri including the with ejection fractions uri component' do
        subject.build.to_s.should match(/\/with\/ejection_fractions/)
      end

    end

    context 'when empty values are given and the uri is built' do

      let(:empty_values) { [] }
      let(:params) { {} }

      context 'when type of service whitelist is specified' do

        before(:each) { params[:type_of_service_whitelist] = empty_values }

        it 'raises a Cdris::Gateway::Exceptions::TypesOfServiceNotProvided' do
          expect { subject.from_whitelists_in(params).build.to_s }.to raise_error(Cdris::Gateway::Exceptions::TypesOfServiceNotProvided)
        end

      end

      context 'when subject matter domain whitelist is specified' do

        before(:each) { params[:subject_matter_domain_whitelist] = empty_values }

        it 'raises a Cdris::Gateway::Exceptions::SubjectMatterDomainsNotProvided' do
          expect { subject.from_whitelists_in(params).build.to_s }.to raise_error(Cdris::Gateway::Exceptions::SubjectMatterDomainsNotProvided)
        end

      end

      context 'when snomed procedure whitelist is specified' do

        before(:each) { params[:snomed_procedure_whitelist] = empty_values }

        it 'raises a Cdris::Gateway::Exceptions::SnomedCodesNotProvided' do
          expect { subject.from_whitelists_in(params).build.to_s }.to raise_error(Cdris::Gateway::Exceptions::SnomedCodesNotProvided)
        end

      end

      context 'when icd9 problem whitelist is specified' do

        before(:each) { params[:icd9_problem_whitelist] = empty_values }

        it 'raises a Cdris::Gateway::Exceptions::Icd9CodesNotProvided' do
          expect { subject.from_whitelists_in(params).build.to_s }.to raise_error(Cdris::Gateway::Exceptions::Icd9CodesNotProvided)
        end

      end

      context 'when snomed problem whitelist is specified' do

        before(:each) { params[:snomed_problem_whitelist] = empty_values }

        it 'raises a Cdris::Gateway::Exceptions::SnomedCodesNotProvided' do
          expect { subject.from_whitelists_in(params).build.to_s }.to raise_error(Cdris::Gateway::Exceptions::SnomedCodesNotProvided)
        end

      end

    end

  end

end
