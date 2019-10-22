require 'neutrino/gateway/requestor'
require 'neutrino/gateway/exceptions'

module Neutrino
  module Gateway
    class DataQualityReport < Neutrino::Gateway::Requestor
      private_class_method :new
      class << self
        
        # Get the summary of data quality
        # @param [Hash] options specify query values
        # @return [Hash] NEUTRINO response
        def summary(options = {})
          path = "#{api}/reports/data-quality/summary"
          request(path, options).
            if_400_raise(Neutrino::Gateway::Exceptions::BadRequestError.new()).to_hash
        end

      end
    end
  end
end
