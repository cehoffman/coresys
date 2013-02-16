module ENVHelpers
  ['CC', 'CXX', 'CFLAGS', 'CXFLAGS', 'LDFLAGS'].each do |var|
    class_eval <<-RUBY,__FILE__,__LINE__ + 1
      def #{var.downcase}
        self[#{var.inspect}]
      end

      def #{var.downcase}=(val)
        self[#{var.inspect}] = val.to_s
      end
    RUBY
  end
end

ENV.extend ENVHelpers

ENV.cc ||= 'gcc'
