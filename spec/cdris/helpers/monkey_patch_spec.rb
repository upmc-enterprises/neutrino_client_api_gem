require 'spec_helper'
require_relative 'utc_iso8601_shared_examples'

describe 'ActiveSupport::TimeWithZone' do
  describe '#as_json' do
  subject { time_with_zone.as_json }
    context 'when already in UTC time' do
      let(:time_with_zone) { Time.zone.now }
      it_behaves_like 'a UTC ISO8601 formatted Date/Time with millisecond resolution'
    end

    context 'when in a non-UTC timezone' do
      let(:time_with_zone) { Time.zone.now.in_time_zone('Hawaii') }
      it_behaves_like 'a UTC ISO8601 formatted Date/Time with millisecond resolution'
    end
  end
end

describe 'Time' do
  describe '#as_json' do
    subject { time.as_json }

    context 'when to_json has been called after then monkey patch has loaded' do
      let(:time) { Time.now.utc }

      {}.to_json
      it_behaves_like 'a UTC ISO8601 formatted Date/Time with millisecond resolution'
    end

    context 'when already in UTC time' do
      let(:time) { Time.now.utc }
      it_behaves_like 'a UTC ISO8601 formatted Date/Time with millisecond resolution'
    end

    context 'when in a non-UTC timezone' do
      let(:time) { Time.now }
      it_behaves_like 'a UTC ISO8601 formatted Date/Time with millisecond resolution'
    end
  end
end
