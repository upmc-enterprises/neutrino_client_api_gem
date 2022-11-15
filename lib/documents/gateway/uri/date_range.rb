require 'documents/gateway/exceptions'

module Neutrino
  module Gateway
    module Uri
      class DateRange

        # Sets the start date
        #
        # @param [String] date to start range
        # @return [DateRange] `self`, for method chaining
        def beginning_at(date)
          @start_date = FormattedDate.new date
          self
        end

        # Sets the end date
        #
        # @param [String] date to end range
        # @return [DateRange] `self`, for method chaining
        def ending_at(date)
          set_end_date_and_raise_error_if_end_is_eariler_than_start(date)
          self
        end

        # Gets the URI specifying the given dates
        #
        # @return [String] the URI specifying dates, or an empty String if either date is `nil`
        def to_s
          uri_or_empty_string_if_either_date_is_nil
        end

        private

        def set_end_date_and_raise_error_if_end_is_eariler_than_start(end_date)
          @end_date = FormattedDate.new end_date
          fail Documents::Gateway::Exceptions::TimeWindowError if @end_date.earlier_than? @start_date
        end

        def uri_or_empty_string_if_either_date_is_nil
          either_date_is_nil? ? '' : uri_from_dates
        end

        def uri_from_dates
          "/document_creation_between#{@start_date.to_uri}#{@end_date.to_uri}"
        end

        def either_date_is_nil?
          @start_date.nil? || @end_date.nil?
        end

      end

      class FormattedDate

        # Constructs a `FormattedDate`
        #
        # @param [String] a_date from which to format
        def initialize(a_date)
          @date = a_date
          validate_date
        end

        # Whether `self` is earlier than another
        #
        # @param [FormattedDate] other date
        # @return [Boolean] `true` if `self` is earlier, `false` otherwise
        def earlier_than?(other)
          return false if @date.nil? || other.to_s.nil?
          s_to_date(other.to_s) > s_to_date(@date)
        end

        # Gets the formatted date
        #
        # @return [String] the formatted date
        def to_s
          @date
        end

        # Whether the formatted date is `nil`
        #
        # @return [Boolean] `true` if formatted date is `nil`, othersise `false`
        def nil?
          @date.nil?
        end

        # Gets a URI of the formatted date
        #
        # @return [String] a URI of the formatted date
        def to_uri
          date_as_uri_or_empty_if_nil
        end

        private

        def date_as_uri_or_empty_if_nil
          @date.nil? ? '' : "/#{@date}"
        end

        def s_to_date(date_as_string)
          Time.parse date_as_string
        end

        def validate_date
          fail Documents::Gateway::Exceptions::TimeFormatError unless @date.nil? ||  @date.match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
        end

      end
    end
  end
end
