module ApiAuth

  module RequestDrivers # :nodoc:
    class RestClientRequest # :nodoc:

      # Modify existing fetch_headers to fetch both normal headers and processed headers.
      # Requried for support because RestClient payload information is only added to
      # processed headers by default.
      def fetch_headers
        capitalize_keys @request.headers.merge(@request.processed_headers)
      end

    end
  end

  class Headers

    # Modifies existing canonical_string method to support https messages
    def canonical_string
      [@request.content_type,
       @request.content_md5,
       @request.request_uri.gsub(/https?:\/\/[^(,|\?|\/)]*/, ''), # remove host
       @request.timestamp
      ].join(',')
    end
  end

end
