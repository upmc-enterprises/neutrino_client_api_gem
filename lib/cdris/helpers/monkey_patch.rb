class Object
  # Returns the `String` cast of `self`
  #
  # @return [String] the `String` cast of `self`
  def gateway_to_param
    to_s
  end

  # Gets `self` as query params
  #
  # @param [String] key the key to specify
  # @return [String] `self` made into query params
  def gateway_to_query(key)
    require 'cgi' unless defined?(CGI) && defined?(CGI.escape)
    "#{CGI.escape(key.gateway_to_param)}=#{CGI.escape(gateway_to_param.to_s)}"
  end
end

class Hash
  # Gets self as query params
  #
  # @param [String] namespace that the query uses
  # @return [String] `self` as query params
  def gateway_to_param(namespace = nil)
    map do |key, value|
      value.gateway_to_query(namespace ? "#{namespace}[#{key}]" : key)
    end.sort * '&'
  end
  alias_method :gateway_to_query, :gateway_to_param
end
