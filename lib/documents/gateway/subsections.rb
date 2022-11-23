require 'documents/gateway/requestor'
require 'documents/gateway/exceptions'

module Documents
  module Gateway
    class Subsections < Documents::Gateway::Requestor
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
