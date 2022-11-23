require 'documents/api/client'
require 'documents/gateway/requestor'

module Documents
  module Gateway
    class NamedQuery < Documents::Gateway::Requestor
      private_class_method :new
      class << self

        # Gets a named query
        #
        # @param [String] name of the query
        # @param [Hash] options specify query values
        # @return [Hash] a named query
        def get(name, options = {})
          path = "#{base_uri}/#{name}"
          request(path, options).if_404_raise(Documents::Gateway::Exceptions::NamedQueryNotFoundError)
                                .to_hash
        end

        # Gets known named queries
        #
        # @param [Hash] options specify query values
        # @return [Hash] known queries
        def known_queries(options = {})
          path = base_uri
          request(path, options).to_hash
        end

        # Gets the base URI for named queries
        #
        # @return [String] the base URI for named queries
        def base_uri
          "#{api}/named_query"
        end
      end
    end
  end
end
