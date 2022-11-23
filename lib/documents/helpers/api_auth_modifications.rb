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
    def canonical_string(override_method = nil, headers_to_sign = [])
      request_method = override_method || @request.http_method

      raise ArgumentError, 'unable to determine the http method from the request, please supply an override' if request_method.nil?

      headers = @request.fetch_headers
      canonical_array = [@request.content_type,
                         @request.content_md5,
                         @request.request_uri.gsub(/https?:\/\/[^(,|\?|\/)]*/, ''),
                         @request.timestamp]

      if headers_to_sign.is_a?(Array) && headers_to_sign.any?
        headers_to_sign.each { |h| canonical_array << headers[h] if headers[h].present? }
      end

      canonical_array.join(',')
    end

  end

end
