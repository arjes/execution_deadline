# frozen_string_literal: true

require 'pry'
require 'spec_helper'

RSpec.describe 'deadline declaration' do
  describe 'backwards compatible helpers include' do
    let(:klass) do
      Module.new do
        extend ExecutionDeadline::Helpers

        deadline in: 1
        def self.foo
          sleep 1.1
        end

      end
    end

    it 'rasies if execution time expires in the execution block' do
      expect { klass.foo }.to raise_error ExecutionDeadline::DeadlineExceeded
    end
  end

  describe 'including instead of extending' do
    let(:klass) do
      Module.new do
        include ExecutionDeadline

        deadline in: 1
        def self.foo
          sleep 1.1
        end

      end
    end

    it 'rasies if execution time expires in the execution block' do
      expect { klass.foo }.to raise_error ExecutionDeadline::DeadlineExceeded
    end
  end

  describe 'deadlining a module method' do
    let(:klass) do
      Module.new do
        extend ExecutionDeadline

        deadline in: 1
        def self.foo
          sleep 1.1
        end

      end
    end

    it 'rasies if execution time expires in the execution block' do
      expect { klass.foo }.to raise_error ExecutionDeadline::DeadlineExceeded
    end
  end

  describe 'deadlining a class method' do
    let(:klass) do
      Class.new do
        extend ExecutionDeadline

        deadline in: 1
        def self.foo
          sleep 1.1
        end

      end
    end

    it 'rasies if execution time expires in the execution block' do
      expect { klass.foo }.to raise_error ExecutionDeadline::DeadlineExceeded
    end
  end

  describe 'deadlining an instance method' do
    let(:klass) do
      Class.new do
        extend ExecutionDeadline

        deadline in: 1
        def foo
          sleep 1.1
          bar
        end

        deadline in: 1, interruptible: true
        def interruptible_foo
          sleep 1.1
          bar
        end

        def bar
        end
      end
    end

    it 'rasies if execution time expires in the execution block' do
      expect { klass.new.foo }.to raise_error ExecutionDeadline::DeadlineExceeded
    end

    it 'still calls bar' do
      instance = klass.new
      expect(instance).to receive(:bar)
      instance.foo rescue nil
    end

    it 'aborts before calling bar' do
      instance = klass.new
      expect(instance).not_to receive(:bar)
      expect { klass.new.foo }.to raise_error ExecutionDeadline::DeadlineExceeded
    end
  end

  describe 'inheritance of deadlines' do
    let(:klass) do
      Class.new do
        extend ExecutionDeadline

        deadline in: 1
        def foo
          sleep 1.1
        end
      end
    end

    it 'rasies if execution time expires in the execution block' do
      new_klass = Class.new(klass) {}
      expect { new_klass.new.foo }.to raise_error ExecutionDeadline::DeadlineExceeded
    end
  end
end
