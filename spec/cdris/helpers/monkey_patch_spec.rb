require './lib/cdris/helpers/monkey_patch'

describe Object do

  describe '.blank?' do

    it 'is blank when it is nil' do
      nil.blank?.should == true
    end

    it 'is blank when it is false' do
      false.blank?.should == true
    end

    it 'is blank when it is []' do
      [].blank?.should == true
    end

    it 'is blank when it is {}' do
      {}.blank?.should == true
    end

    it 'is blank when it is ""' do
      ''.blank?.should == true
    end

    it 'is blank when it is a sequence of whitespace' do
      " \t\n\r\n ".blank?.should == true
    end

    it 'is not blank when some letters are given' do
      'foo'.blank?.should == false
    end

    it 'is not blank when it is not an empty structure and it is not a string' do
      Regexp.new('foo').blank?.should == false
    end

  end

end
