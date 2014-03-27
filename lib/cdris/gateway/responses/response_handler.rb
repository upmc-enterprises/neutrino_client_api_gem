require 'json'

module Cdris
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
        # @return [Hash] the response body (from JSON)
        def to_hash
          begin
            JSON.parse(@response.body)
          rescue JSON::ParserError => e
            raise Exceptions::JsonBodyParseError.new(@response.body)
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
          is_same_as_response_code?(other_code)
        end

        # Whether the response code is not a code in question
        #
        # @param [String|Integer] other_code the code to compare
        # @return [Boolean] `false` if the other code is the same as the response, `true` otherwise
        def code_is_not?(other_code)
          not is_same_as_response_code?(other_code)
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

        private

        def if_asked_code_is_the_same_as_response_code_then_raise(exception)
          raise exception if is_same_as_response_code?(@current_code)
        end

        def is_same_as_response_code?(code)
          @response.code.to_s == code.to_s
        end

        def ensure_format_and_bounds_are_observed_by(name)
          raise NoMethodError if not name.to_s.match(/if_\d{3}_raise/)
          @current_code = get_code_from(name)

          raise NoMethodError if @current_code > MAX_HTTP_STATUS
        end

        def get_code_from(name)
          code = name.to_s
                     .match(/if_(\d{3})_raise/)
                     .to_a[1]
                     .to_i
        end

      end

    end

  end

end
