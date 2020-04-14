require './spec/spec_helper'
require './lib/neutrino/gateway/responses/response_handler'
require './lib/neutrino/gateway/exceptions'

describe Neutrino::Gateway::Responses::ResponseHandler do
  let(:response_handler) { Neutrino::Gateway::Responses::ResponseHandler.new }

  describe '.to_s' do

    let(:ok_response) { Object.new }
    let(:ok_body) { 'I am the response body' }

    before(:each) do
      allow(ok_response).to receive(:body).and_return(ok_body)
      allow(ok_response).to receive(:code).and_return('200')

    end

    it 'returns the body of a response' do
      expect(subject
        .considering(ok_response)
        .to_s).to eq(ok_body)
    end

    it 'returns the body of a response when a status code error out is given that is not the status code of the response' do
      expect(subject
        .considering(ok_response)
        .if_424_raise(anything)
        .to_s).to eq(ok_body)
    end

  end

  describe '.content_type' do

    context 'when a response with the content-type header is considered' do

      before(:each) { subject.considering('content-type' => 'foo/bar') }

      it "returns the header's content type" do
        expect(subject.content_type).to eq('foo/bar')
      end

    end

    context 'when a response with no content-type header is considered' do

      before(:each) { subject.considering({}) }

      it 'returns a default content type of text/plain' do
        expect(subject.content_type).to eq('text/plain')
      end

    end

  end

  describe '#data_and_type' do
    subject { response_handler.data_and_type }

    context 'when considering a response with a body and content-type' do
      let(:response) { double('Response', body: 'Foo', :[] => 'text/foo') }
      before(:each) { response_handler.considering(response) }

      it { should == { data: 'Foo', type: 'text/foo' } }

      context 'and the response handler is told to raise an exception if a non successful code is given' do
        before(:each) { response_handler.if_non_200_raise(Exception) }

        ['200', rand(100)+200, rand(100)+200, rand(100)+200, rand(100)+200].each do |successful_code|
          context "and the response has a 200-family response of #{successful_code}" do
            before(:each) { allow(response).to receive(:code).and_return(successful_code) }

            specify { expect { subject }.to_not raise_error }
          end
        end

        context 'and the response has a non-200 family status code' do
          before(:each) { allow(response).to receive(:code).and_return('329') }

          specify { expect { subject }.to raise_error(Exception) }
        end
      end
    end
  end

  describe '.if_404_raise' do

    let(:response_404) { Object.new }
    let(:example_exception) { 'example exception' }

    before(:each) do
      allow(response_404).to receive(:code).and_return('404')
    end

    it 'raises the passed exception when a response with a 404 is given' do
      expect do
        subject
        .considering(response_404)
        .if_404_raise(example_exception)
      end.to raise_error(example_exception)
    end

  end

  describe '#to_hash' do
    subject { response_handler.to_hash }

    let(:response) { double('Response', body: response_json, code: response_code, :'[]' => 'application/json' ) }
    let(:response_code) { '200' }
    let(:response_json) { '{}' }

    context 'when considering a response' do
      before(:each) { response_handler.considering(response) }

      context 'and that response is of non-JSON format' do

        let(:response) { double('Response', body: response_non_json, code: response_code, :'[]' => 'text/csv' ) }
        let(:response_non_json) { 'i,am,not,json' }

        it { should == response_non_json }

      end

      context 'and that response has valid JSON' do
        let(:valid_json_string) { '{ "foo": "bar", "fizz": "buzz", "cooler_than_winter": true }' }
        let(:response_json) { valid_json_string }

        it { should == JSON.parse(response_json) }
      end

      context 'and that response has invalid JSON' do
        let(:response_json) { "}foobar{" }

        specify { expect { subject }.to raise_error(Neutrino::Gateway::Exceptions::JsonBodyParseError) }
      end

      context 'and the ResponseHandler is told to raise an exception for non-200 codes' do
        before(:each) { response_handler.if_non_200_raise(Exception) }

        context 'and the response has a 200 code' do
          let(:response_code) { '200' }

          it { should == JSON.parse(response_json) }
        end

        context 'and the response does not have a 200 code' do
          let(:response_code) { '324' }

          specify { expect { subject }.to raise_error(Exception) }

          context 'and told to raise a more specific error type for the given status code' do
            specify { expect { response_handler.if_324_raise(ArgumentError) }.to raise_error(ArgumentError) }
          end

        end

      end

    end

  end

  describe '.code_is?' do

    let(:response_300) { Object.new }

    before(:each) do
      allow(response_300).to receive(:code).and_return('300')
    end

    it 'returns true if the considered request has the checked code' do
      expect(subject
      .considering(response_300)
      .code_is?(300)).to eq(true)
    end

    it 'returns false if the considered request has a different code than is checked' do
      expect(subject
      .considering(response_300)
      .code_is?(200)).to eq(false)
    end

  end

  describe '.code_is_not?' do

    let(:response_300) { Object.new }

    before(:each) do
      allow(response_300).to receive(:code).and_return('300')
    end

    it 'returns true if the considered request has a code that is different than the checked code' do
      expect(subject.considering(response_300)
             .code_is_not?(301)).to eq(true)
    end

    it 'returns false if the considered request has the same code as is checked' do
      expect(subject
      .considering(response_300)
      .code_is_not?(300)).to eq(false)
    end

  end

  describe '.method_missing' do

    let(:example_exception) { "I'm an example exception" }
    let(:response_300) { Object.new }
    let(:response_505) { Object.new }

    before(:each) do
      allow(response_300).to receive(:code).and_return('300')
      allow(response_505).to receive(:code).and_return('505')
    end

    it 'raises a NoMethodError when a method that does not look like "if_<response-code>_raise is called"' do
      expect do
        subject
        .foobar_bla_blah_sadfdsa
      end.to raise_error(NoMethodError)
    end

    it 'raises the passed error when a response with the specified status code is passed' do
      expect do
        subject
        .considering(response_300)
        .if_300_raise(example_exception)
      end.to raise_error(example_exception)
    end

    it 'does not raise the passed error when a response with a different status code is passed' do
      expect do
        subject
        .considering(response_505)
        .if_300_raise(example_exception)
      end.not_to raise_error
    end

    it 'raises a NoMethodError when a method that does not contain a number where the status code should be is called' do
      expect do
        subject
        .if_bar_raise(anything)
      end.to raise_error(NoMethodError)
    end

    it 'raises a NoMethodError if a method is called whose status code is beyond 505' do
      expect do
        subject
        .if_506_raise(anything)
      end.to raise_error(NoMethodError)
    end

    it 'raises a NoMethodError if a method is called whose status code is below 100' do
      expect do
        subject
        .if_99_raise(anything)
      end.to raise_error(NoMethodError)
    end

    it 'does not raise a NoMethodError for a bunch of valid status codes following the "if_<response-code>_raise" pattern' do
      expect do
        ['100', '200', '404', '505'].each do |code|
          subject
            .considering(response_300)
            .send("if_#{code}_raise", anything)
        end
      end.not_to raise_error
    end

    it 'does not raise an exception when a series of if_<code>_raise are chained and the response in consideration does not have any of their codes' do
      expect do
        subject
        .considering(response_300)
        .if_404_raise(anything)
        .if_301_raise(anything)
        .if_201_raise(anything)
      end.not_to raise_error
    end

    it 'raises the custom exception provided at the end of a chain if that method has the code of the response' do
      expect do
        subject
        .considering(response_300)
        .if_333_raise(anything)
        .if_222_raise(anything)
        .if_300_raise(example_exception)
      end.to raise_error(example_exception)
    end

  end

  describe '.with_general_exception_check' do

    let(:response) { Object.new }
    let(:response_code) { '12345' }
    let(:response_message) { {error: 'some error'}.to_json }
    let(:exception) { Exception.new('some exception') }

    before(:each) do
      allow(response).to receive(:code).and_return(response_code)
      allow(response).to receive(:body).and_return(response_message)
    end

    context 'when exception code matches response code but exception message does not match response error' do
      it 'returns the result of the ResponseHandler block' do
        expect(subject.considering(response).with_general_exception_check('12345', /another.*error/i , exception)).to eq(subject.considering(response))
      end
    end

    context 'when exception code and exception message do not match' do
      it 'returns the result of the ResponseHandler block' do
        expect(subject.considering(response).with_general_exception_check('90210', /beverly.*hills/i , exception)).to eq(subject.considering(response))
      end
    end

    context 'when exception code and exception message match' do
      it 'raises the specified exception' do
        expect{ subject.considering(response).with_general_exception_check('12345', /some.*error/i , exception) }.to raise_error(exception)
      end
    end

  end

end
