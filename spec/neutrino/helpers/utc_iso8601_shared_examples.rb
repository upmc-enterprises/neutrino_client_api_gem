require 'spec_helper'

shared_examples 'a UTC ISO8601 formatted Date/Time with millisecond resolution' do
  it { should match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/) }
  it { should match(/T[\d\:\.]+Z$/) }
  it { should match(/T[\d\:]+\.(\d+).$/) }
end
