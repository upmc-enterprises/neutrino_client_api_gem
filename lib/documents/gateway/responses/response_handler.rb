require 'json'

module Documents
  module Gateway
    module Responses
      class ResponseHandler

        MAX_HTTP_STATUS = 505

        # Sets the response to handle
        #
        # @param [Net::HttpResponse] response to consider for handling
        # @return [ResponseHandler] `self`, for method chaining
        def considering(response)
          @response = response
          self
        end

        # Gets the response body
        #
        # @return [String] the response body
        def to_s
          @response.body
        end

        # Gets the response body
        #
        # @return [Hash, String] the response body (from JSON) if content
        #   type is json, raw body as string otherwise
        def to_hash
          fail_on_non_200_family_if_specified

          if @response['content-type'].nil? || @response['content-type'].include?('json')
            begin
              JSON.parse(@response.body)
            rescue JSON::ParserError
              raise Exceptions::JsonBodyParseError.new(@response.body)
            end
          else
            @response.body
          end
        end

        # Gets the considered response's content type
        #
        # @return [String] the content type
        def content_type
          @response['content-type'].nil? ? 'text/plain' : @response['content-type']
        end

        # Gets a value and its mime-type
        #
        # @return [Hash] `:data` specifying the data, and `:type` specifying the data's mime type
        def data_and_type
          fail_on_non_200_family_if_specified

          {
            data: to_s,
            type: content_type
          }
        end

        # Whether the response code is a code in question
        #
        # @param [String|Integer] other_code the code to compare
        # @return [Boolean] `true` if the other code is the same as the response, `false` otherwise
        def code_is?(other_code)
          same_as_response_code?(other_code)
        end

        # Tells the ResponseHandler to raise an exception, upon non-successful
        #  status codes
        #
        # @param [Class] exception_klass class of exception to raise
        # @return [ResponseHandler] `self`, for method chaining
        def if_non_200_raise(exception_klass)
          @non_200_exception = exception_klass
          self
        end

        # Whether the response code is not a code in question
        #
        # @param [String|Integer] other_code the code to compare
        # @return [Boolean] `false` if the other code is the same as the response, `true` otherwise
        def code_is_not?(other_code)
          !same_as_response_code?(other_code)
        end

        # Checks for methods of form if_<code>_raise, where <code> is a valid HTTP status code
        #
        # @param [String] name of the method
        # @return [ResponseHandler] `self`, for method chaining
        # @raise [NoMethodError] when name doesn't match `if_<code>_raise` where <code> is a valid
        #   HTTP status code
        # @raise [Object] the custom exception passed as `args[0]`, when the status code specified
        #   in the method name (<code>) is the same as the response code
        def method_missing(name, *args, &block)
          ensure_format_and_bounds_are_observed_by(name)
          if_asked_code_is_the_same_as_response_code_then_raise(args[0])
          self
        end

        # Returns the result of the ResponseHandler block unless the patient identity set was in error
        # @return [Responses::ResponseHandler] the http response that was passed to the method
        # @raise [Documents::Gateway::Exceptions::PatientIdentitySetInError] if the patient identity set is in error
        def with_patient_identity_set_in_error_check
          if_403_raise(Documents::Gateway::Exceptions::PatientIdentitySetInError)
        end

        # Returns the result of the ResponseHandler block unless the exception arguments match
        # @param exception_code [String] exception code
        # @param exception_regexp [Regexp] regular expression matching the exception message
        # @param exception [Exception] exception to raise
        # @return [Responses::ResponseHandler] the http response that was passed to the method
        # @raise [Exception] if the exception_code and exception_message match
        def with_general_exception_check(exception_code, exception_regexp, exception)
          if @response.code == exception_code && exception_regexp.match(JSON.parse(@response.body)['error'])
            raise(exception)
          else
            self
          end
        rescue JSON::ParserError
          self
        end

        private

        def if_asked_code_is_the_same_as_response_code_then_raise(exception)
          fail exception if same_as_response_code?(@current_code)
        end

        def same_as_response_code?(code)
          @response.code.to_s == code.to_s
        end

        def response_successful?
          @response.code.to_s[0] == '2'
        end

        def ensure_format_and_bounds_are_observed_by(name)
          fail NoMethodError, name.to_s unless name.to_s.match(/if_\d{3}_raise/)
          @current_code = get_code_from(name)

          fail NoMethodError, name.to_s if @current_code > MAX_HTTP_STATUS
        end

        def get_code_from(name)
          name.to_s
            .match(/if_(\d{3})_raise/)
            .to_a[1]
            .to_i
        end

        def fail_on_non_200_family_if_specified
          if @non_200_exception && !response_successful?
            fail @non_200_exception, '', ["Returned response code: #{@response.code}, with body: #{@response.body}"]
          end
        end

      end

    end

  end

end
