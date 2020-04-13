require 'neutrino/gateway/exceptions'
require 'neutrino/api/client'

module Neutrino
  module Gateway
    module Uri
      class Whitelist

        # Creates a new `WhitelistUri`
        #
        # @return [WhitelistUri] constructed object
        def initialize
          @value = nil
          @template = ''
          @component = ''
        end

        # Sets the base template for URI
        #
        # @param [String] template to use for generating the URI
        # @return [WhitelistUri] `self`, for method chaining
        def with_template(template)
          @template = template
          self
        end

        # Sets the value (singular) to be subbed into the template
        #
        # @param [Object] value to be subbed into the template at {value}
        # @return [WhitelistUri] `self`, for method chaining
        def and_value(value)
          @value = value
          self
        end

        # Sets the value, joining multiple values, to be subbed into the template
        #
        # @param [Array] values to be joined by comma and subbed into the template at {value}
        # @return [WhitelistUri] `self`, for method chaining
        def and_values(values)
          @value = values.join ','
          self
        end

        # Sets an additional component to be appended when `to_s` is called
        #
        # @param [object] name of the component
        # @return [WhitelistUri] `self`, for method chaining
        def append_component(name)
          @component = "/#{name}"
          self
        end

        # Sets the custom exception to raise when `@value` is not set
        #
        # @param [Object] error to be raised when the value is not correct
        # @return [WhitelistUri] `self`, for method chaining
        def error_on_empty(error)
          @error = error
          self
        end

        # Gets the URI component from the given template and value(s)
        #
        # @return [String] the URI component
        # @raise [Object] the custom exception specified earlier, when a value is empty
        def to_s
          fail @error if @error && @value.empty?

          @template.sub('{value}', URI.encode(@value.to_s)) + @component
        end

      end

    end

  end

end
