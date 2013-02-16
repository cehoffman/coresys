module ENV
  ['CC', 'CXX', 'CFLAGS', 'CXFLAGS', 'LDFLAGS'].each do |var|
    class_eval <<-RUBY,__FILE__,__LINE__ + 1
      def #{var.downcase}
        self[#{var.inspect}]
      end
    RUBY
  end
end
