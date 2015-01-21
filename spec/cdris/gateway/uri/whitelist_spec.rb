require './spec/spec_helper'
require './lib/cdris/gateway/uri/whitelist'

describe Cdris::Gateway::Uri::Whitelist do

  describe '.to_s' do

    it 'returns a template if that is all that is specified' do
      expect(described_class.new
               .with_template('this_is_a_test_duh')
               .to_s).to eq('this_is_a_test_duh')
    end

    it 'injects the whitelist value into the {value} placeholder of the uri template' do
      expect(described_class.new
               .with_template('foobar/{value}')
               .and_value('spameggs')
               .to_s).to eq('foobar/spameggs')
    end

    it 'injects non-string whitelist values into the {value} placeholder of the uri template' do
      [3.1416, 4, nil].each do |value|
        expect(described_class.new
                    .with_template('foobar/{value}')
                    .and_value(value)
                    .to_s).to eq("foobar/#{value}")
      end
    end

    it 'does nothing when a placeholder other than {value} is used' do
      expect(described_class.new
               .with_template('foobar/{vlu}')
               .and_value('spameggs')
               .to_s).to eq('foobar/{vlu}')
    end

    it 'injects the whitelist values, separated by a comma, into the {value} placeholder of the uri template' do
      expect(described_class.new
               .with_template('foobar/{value}')
               .and_values(['spam', 'eggs'])
               .to_s).to eq('foobar/spam,eggs')
    end

    it 'throws the specified error when the provided values are an empty list' do
      expect do
        described_class.new
                 .with_template(anything)
                 .and_values([])
                 .error_on_empty('Uh Oh...')
                 .to_s
      end.to raise_error('Uh Oh...')
    end

    it 'throws the specified error when the provided value is the empty string' do
      expect do
        described_class.new
                 .with_template(anything)
                 .and_value('')
                 .error_on_empty('Foobar')
                 .to_s
      end.to raise_error('Foobar')
    end

    it 'returns an empty string when an empty template and value are given' do
      expect(described_class.new
               .with_template('')
               .and_value('')
               .to_s).to eq('')
    end

    it 'returns an empty string when only an empty string is given for a template' do
      expect(described_class.new
               .with_template('')
               .to_s).to eq('')
    end

    it 'returns an empty string when it has only been initialized and nothing has been done to it' do
      expect(described_class.new.to_s).to eq('')
    end

    it 'appends on a uri component if no error is thrown' do
      expect(described_class.new
               .with_template('foobar')
               .append_component('craycray')
               .to_s).to eq('foobar/craycray')
    end

  end

end
