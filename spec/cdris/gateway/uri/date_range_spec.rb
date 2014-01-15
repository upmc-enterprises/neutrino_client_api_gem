require './lib/cdris/gateway/uri/date_range'
require './lib/cdris/gateway/exceptions'

describe Cdris::Gateway::Uri::DateRange do

  let(:date_in_2013) { '2013-01-01T01:01:01Z' }
  let(:date_in_2014) { '2014-01-01T01:01:01Z' }

  describe '.beginning_at' do
    
    it 'raises a TimeFormatError when it is given a begin date that is not properly formatted' do
      expect { described_class.new.beginning_at('foo') }.to raise_error(Cdris::Gateway::Exceptions::TimeFormatError)
    end

  end

  describe '.ending_at' do

    it 'works when an end date after the beginning start date is given' do
      range = described_class.new
                       .beginning_at(date_in_2013)
                       .ending_at(date_in_2014)
    end

    it 'raises a TimeFormatError when it is given a end date that is not properly formatted' do
      expect { described_class.new.ending_at('foo') }.to raise_error(Cdris::Gateway::Exceptions::TimeFormatError)
    end
    
    it 'raises a TimeWindowError when it is given a begin date that is after its end date' do
      range = described_class.new.beginning_at(date_in_2014)

      expect { range.ending_at(date_in_2013) }.to raise_error(Cdris::Gateway::Exceptions::TimeWindowError)
    end

  end

  describe '.to_s' do
    
    it 'returns the begin date and the end date separated by a forward slash given a valid beginning and ending date' do
      described_class.new
               .beginning_at(date_in_2013)
               .ending_at(date_in_2014)
               .to_s.should == "/document_creation_between/#{date_in_2013}/#{date_in_2014}"
    end

    it 'returns empty string given the beginning date is nil' do
      described_class.new
               .beginning_at(nil)
               .ending_at(date_in_2014)
               .to_s.should == ''
    end

    it 'returns empty string given the beginning date is nil' do
      described_class.new
               .beginning_at(date_in_2013)
               .ending_at(nil)
               .to_s.should == ''
    end

  end

end

describe Cdris::Gateway::Uri::FormattedDate do

  let(:date_in_2014) { '2014-01-01T00:00:00Z' }
  let(:date_in_2013) { '2013-01-01T01:01:01Z' }

  describe '.initialize' do

    it 'works when a date in the expected format is given' do
      described_class.new date_in_2014
    end

    it 'works when a nil value is passed in' do
      described_class.new nil
    end

    it 'raises a TimeFormatError when given a string that is not in the correct format' do
      expect { described_class.new 'foo' }.to raise_error(Cdris::Gateway::Exceptions::TimeFormatError)
    end

  end

  describe '.earlier_than?' do

    it 'is true given the calling object was initialized with an earlier date than the passed object' do
      calling_object = described_class.new date_in_2013
      passed_object = described_class.new date_in_2014

      (calling_object.earlier_than? passed_object).should == true
    end

    it 'is false given the calling object was initialized with a later date than the passed object' do
      calling_object = described_class.new date_in_2014
      passed_object = described_class.new date_in_2013

      (calling_object.earlier_than? passed_object).should == false
    end

    it 'is false given the calling object was initialized with the same date as the passed object' do
      calling_object = described_class.new date_in_2014
      passed_object = described_class.new date_in_2014

      (calling_object.earlier_than? passed_object).should == false
    end

    it 'is false given the calling object was initialized with nil' do
      calling_object = described_class.new nil
      passed_object = described_class.new date_in_2014

      (calling_object.earlier_than? passed_object).should == false
    end

    it 'is false given the passed object was initialized with nil' do
      calling_object = described_class.new date_in_2013
      passed_object = described_class.new nil

      (calling_object.earlier_than? passed_object).should == false
    end

  end

  describe '.to_uri' do
    
    it 'gets the original, beginning with a slash' do
      formatted_date = described_class.new date_in_2013

      formatted_date.to_uri.should == "/#{date_in_2013}"
    end

    it 'gets an empty string if the original value was nil' do
      formatted_date = described_class.new nil

      formatted_date.to_uri.should == ''
    end

  end

  describe '.nil?' do

    it 'returns true if object was initialized with nil' do
      formatted_date = described_class.new nil

      formatted_date.nil?.should == true
    end

  end

end
