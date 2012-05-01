class String
  def undent
    gsub(/^ #{slice(/^ +/).length}/, '')
  end

  def camelcase
    capitalize.gsub(/[-_.\s]([a-zA-Z])/) { $1.upcase }.gsub('+', 'x')
  end

  # Method used in Rails 3
  def underscore
    gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
      gsub(/([a-z\d])(A-Z)/, '\1_\2').
      tr('-', '_').downcase
  end
end
