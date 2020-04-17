require 'execution_deadline/deadliner'

module ExecutionDeadline
  module MethodProxy
    def self.for_class(klass)
      find_for_class(klass) || install_on_class(klass)
    end

    def self.find_for_class(klass)
      klass.ancestors.detect do |a|
        a.is_a?(Deadliner) &&
          a._execution_deadline_built_for == klass
      end
    end

    def self.install_on_class(klass)
      construct_for_class(klass).tap do |m|
        klass.prepend(m)
      end
    end

    def self.construct_for_class(klass)
      Module.new do
        extend Deadliner
      end.tap { |m| m._execution_deadline_built_for = klass }
    end
  end
end
