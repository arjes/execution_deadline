# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Inheritance of Method Defined' do
  describe 'inheritance of instance method defined' do
    let(:other_meta_module) do
      Module.new do
        def call_times
          @call_times ||= 0
        end

        attr_writer :call_times

        def method_added(method_added)
          self.call_times += 1
          super
        end
      end
    end

    let(:klass) do
      other = other_meta_module
      Class.new do
        extend other
        extend ExecutionDeadline::Helpers

        def bar; end

        deadline runs_for: 1
        def foo; end
      end
    end

    it 'called the super method three times' do
      # 1 - Bar
      # 3 - foo
      expect(klass.call_times).to eq 2
    end
  end

  describe 'inheritance of class method defined' do
    let(:other_meta_module) do
      Module.new do
        def call_times
          @call_times ||= 0
        end

        attr_writer :call_times

        def singleton_method_added(method_added)
          self.call_times += 1
          super
        end
      end
    end

    let(:klass) do
      other = other_meta_module
      Class.new do
        extend other
        extend ExecutionDeadline::Helpers

        def self.bar; end

        deadline runs_for: 1
        def self.foo; end
      end
    end

    it 'called the super method three times' do
      # 1 - Bar
      # 2 - _foo_without_deadline
      # 3 - foo
      expect(klass.call_times).to eq 2
    end
  end
end
