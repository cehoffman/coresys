module Coresys
  module DownloadStrategy
    class Abstract
      def initialize(formula)
        @formula = formula
      end

      def verify; end

      def unique_name
        @formula.name
      end

      def cached_path
        @cached_path ||= Coresys.cache! + unique_name
      end
    end
  end
end
