class String
  def undent
    gsub(/^ #{slice(/^ +/).length}/, '')
  end

  def camelcase
    capitalize.gsub(/[-_.\s]([a-zA-Z])/) { $1.upcase }.gsub('+', 'x')
  end
end
