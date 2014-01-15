require './spec/spec_helper'
require './lib/cdris/gateway/responses/response_handler'

describe Cdris::Gateway::Responses::ResponseHandler do

  describe '.to_s' do

    let(:ok_response) { Object.new }
    let(:ok_body) { "I am the response body" }

    before(:each) do
      ok_response.stub(:body).and_return(ok_body)
      ok_response.stub(:code).and_return('200')

    end

    it 'returns the body of a response' do
      subject
        .considering(ok_response)
        .to_s.should == ok_body
    end

    it 'returns the body of a response when a status code error out is given that is not the status code of the response' do
      subject
        .considering(ok_response)
        .if_424_raise(anything)
        .to_s.should == ok_body
    end

  end

  describe '.content_type' do

    context 'when a response with the content-type header is considered' do

      before(:each) { subject.considering({ 'content-type' => 'foo/bar' }) }

      it "returns the header's content type" do
        subject.content_type.should == 'foo/bar'
      end

    end

    context 'when a response with no content-type header is considered' do

      before(:each) { subject.considering({}) }

      it 'returns a default content type of text/plain' do
        subject.content_type.should == 'text/plain'
      end

    end

  end

  describe '.data_and_type' do

    context 'when considering a response with a body and content-type' do

      let(:response) { Object.new }

      before(:each) do
        response.stub(:body).and_return("Foo")
        response.stub(:[]).and_return('text/foo')
        subject.considering(response)
      end

      it 'returns a hash of the body and content-type' do
        subject.data_and_type.should == { data: "Foo", type: "text/foo" }
      end

    end

  end

  describe '.if_404_raise' do

    let(:response_404) { Object.new }
    let(:example_exception) { "example exception" }

    before(:each) do
      response_404.stub(:code).and_return('404')
    end

    it 'raises the passed exception when a response with a 404 is given' do
      expect {
        subject
        .considering(response_404)
        .if_404_raise(example_exception)
      }.to raise_error(example_exception)
    end

  end

  describe '.to_hash' do

    let(:example_json_string) { '{ "foo": "bar", "fizz": "buzz", "cooler_than_winter": true }' }
    let(:response_with_json_string_body) { Object.new }

    before(:each) do
      response_with_json_string_body.stub(:body).and_return(example_json_string)
    end

    it 'returns the body of the considered request, parsed from json' do
      subject
      .considering(response_with_json_string_body)
      .to_hash.should == JSON.parse(example_json_string)
    end

    context 'when considering a response that has bad JSON' do

      let(:bad_json) { "fdsagasf" }
      let(:response_with_bad_json) { Object.new }

      before(:each) do
        response_with_bad_json.stub(:body).and_return(bad_json)
        subject.considering(response_with_bad_json)
      end

      it 'raises a JsonBodyParseError with the body as the first error' do
        begin
          subject.to_hash
        rescue Cdris::Gateway::Exceptions::JsonBodyParseError => e
          e.errors.first.should == bad_json
        end
      end

    end

  end

  describe '.code_is?' do

    let(:response_300) { Object.new }

    before(:each) do
      response_300.stub(:code).and_return('300')
    end

    it 'returns true if the considered request has the checked code' do
      subject
      .considering(response_300)
      .code_is?(300).should == true
    end

    it 'returns false if the considered request has a different code than is checked' do
      subject
      .considering(response_300)
      .code_is?(200).should == false
    end

  end

  describe '.code_is_not?' do

    let(:response_300) { Object.new }

    before(:each) do
      response_300.stub(:code).and_return('300')
    end

    it 'returns true if the considered request has a code that is different than the checked code' do
      subject.considering(response_300)
             .code_is_not?(301).should == true
    end

    it 'returns false if the considered request has the same code as is checked' do
      subject
      .considering(response_300)
      .code_is_not?(300).should == false
    end

  end

  describe '.method_missing' do

    let(:example_exception) { "I'm an example exception" }
    let(:response_300) { Object.new }
    let(:response_505) { Object.new }

    before(:each) do
      response_300.stub(:code).and_return('300')
      response_505.stub(:code).and_return('505')
    end

    it 'raises a NoMethodError when a method that does not look like "if_<response-code>_raise is called"' do
      expect {
        subject
        .foobar_bla_blah_sadfdsa()
      }.to raise_error(NoMethodError)
    end

    it 'raises the passed error when a response with the specified status code is passed' do
      expect {
        subject
        .considering(response_300)
        .if_300_raise(example_exception)
      }.to raise_error(example_exception)
    end

    it 'does not raise the passed error when a response with a different status code is passed' do
      expect {
        subject
        .considering(response_505)
        .if_300_raise(example_exception)
      }.not_to raise_error
    end

    it 'raises a NoMethodError when a method that does not contain a number where the status code should be is called' do
      expect {
        subject
        .if_bar_raise(anything)
      }.to raise_error(NoMethodError)
    end

    it 'raises a NoMethodError if a method is called whose status code is beyond 505' do
      expect {
        subject
        .if_506_raise(anything)
      }.to raise_error(NoMethodError)
    end

    it 'raises a NoMethodError if a method is called whose status code is below 100' do
      expect {
        subject
        .if_99_raise(anything)
      }.to raise_error(NoMethodError)
    end

    it 'does not raise a NoMethodError for a bunch of valid status codes following the "if_<response-code>_raise" pattern' do
      expect {
        ['100', '200', '404', '505'].each do |code|
        subject
        .considering(response_300)
        .send("if_#{code}_raise", anything)
        end
      }.not_to raise_error
    end

    it 'does not raise an exception when a series of if_<code>_raise are chained and the response in consideration does not have any of their codes' do
      expect {
        subject
        .considering(response_300)
        .if_404_raise(anything)
        .if_301_raise(anything)
        .if_201_raise(anything)
      }.not_to raise_error
    end

    it 'raises the custom exception provided at the end of a chain if that method has the code of the response' do
      expect {
        subject
        .considering(response_300)
        .if_333_raise(anything)
        .if_222_raise(anything)
        .if_300_raise(example_exception)
      }.to raise_error(example_exception)
    end

  end

end
