require 'cdris/gateway/requestor'
require 'cdris/gateway/exceptions'

module Cdris
  module Gateway
    class Subsections < Cdris::Gateway::Requestor
      private_class_method :new
      class << self

        # Show all subsections
        # @return [Array] All subsections
        def show_subsections(options = {})
          path = base_uri
          request(path, options).to_json
        end

        # Gets the base URI for a subsection
        # @return [String] the base URI for a subsection
        def base_uri
          "#{api}/subsection"
        end

      end
    end
  end
end
