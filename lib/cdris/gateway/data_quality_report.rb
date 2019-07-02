require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class DataQualityReport < Cdris::Gateway::Requestor
      private_class_method :new
      class << self
        
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
