class Object
  # Returns the `String` cast of `self`
  #
  # @return [String] the `String` cast of `self`
  def to_param
    to_s
  end

  # Gets `self` as query params
  #
  # @param [String] key the key to specify
  # @return [String] `self` made into query params
  def to_query(key)
    require 'cgi' unless defined?(CGI) && defined?(CGI.escape)
    "#{CGI.escape(key.to_param)}=#{CGI.escape(to_param.to_s)}"
  end

  # Whether `self` is a "blank" object
  #
  # @return [Boolean] `true` if `nil`, `false`, `[]`, `{}`, `''` or white space, otherwise `false`
  def blank?
    return true if [nil, false, [], {}, ''].include?(self)
    return false unless self.is_a? String
    (self =~ /^\s+$/) == 0
  end
end

class Hash
  # Gets self as query params
  #
  # @param [String] namespace that the query uses
  # @return [String] `self` as query params
  def to_param(namespace = nil)
    map do |key, value|
      value.to_query(namespace ? "#{namespace}[#{key}]" : key)
    end.sort * '&'
  end
  alias_method :to_query, :to_param
end
