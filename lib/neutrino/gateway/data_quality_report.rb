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
            if_400_raise(Neutrino::Gateway::Exceptions::BadRequestError.new).to_hash
        end

        # Update the twelve month volume report by source created at
        # Create a new one if there is no existing report
        # @param [Hash] options specify query values
        # @return [Hash] NEUTRINO response
        def twelve_month_volume_by_source_created_at(options = {})
          path = "#{api}/reports/data-quality/twelve_month_volume_by_source_created_at"
          request(path, options)
            .if_400_raise(Neutrino::Gateway::Exceptions::BadRequestError.new).to_hash
        end

        # Update the twelve month volume report by created at
        # Create a new one if there is no existing report
        # @param [Hash] options specify query values
        # @return [Hash] NEUTRINO response
        def twelve_month_volume_by_created_at(options = {})
          path = "#{api}/reports/data-quality/twelve_month_volume_by_created_at"
          request(path, options)
            .if_400_raise(Neutrino::Gateway::Exceptions::BadRequestError.new).to_hash
        end
      end
    end
  end
end
