require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class DataQualityReport < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # Update the data quality report
        # Create a new one if there is no existing report
        # @param [Hash] options specify query values
        # @return [Hash] CDRIS response
        def create_or_update(options = {})
          path = "#{api}/reports/data-quality/summary/generate"
          request(path, options.merge!(method: :post)).
            if_400_raise(Cdris::Gateway::Exceptions::BadRequestError.new()).to_hash
        end

        # Get the summary of data quality
        # @param [Hash] options specify query values
        # @return [Hash] CDRIS response
        def summary(options = {})
          path = "#{api}/reports/data-quality/summary"
          request(path, options).
            if_400_raise(Cdris::Gateway::Exceptions::BadRequestError.new()).to_hash
        end

      end
    end
  end
end
