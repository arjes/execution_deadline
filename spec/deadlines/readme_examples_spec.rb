# frozen_string_literal: true

require 'pry'
require 'spec_helper'

RSpec.describe 'README examples' do
  let(:instance) { klass.new }

  describe 'raising a custom error message' do
    let(:err_klass) { klass.const_get(:CustomError) }
    let(:klass) do
      Module.new do
        class CustomError < StandardError; end
        extend ExecutionDeadline::Helpers

        deadline in: 1, raises: CustomError
        def self.runs_out_of_time
          sub_method_1
          sub_method_1
        end

        deadline runs_for: 0.6
        def self.sub_method_1
          sleep 0.8
        end

        deadline in: 1, raises: CustomError
        def self.runs_over_time
          runs_over
        end

        deadline runs_for: 0.5
        def self.runs_over
          sleep 1.1
        end
      end
    end

    it 'rasies custom errors' do
      expect { klass.runs_over_time }.to raise_error err_klass
      expect { klass.runs_out_of_time }.to raise_error err_klass
    end
  end

  describe 'their usage on module methods' do
    let(:klass) do
      Module.new do
        extend ExecutionDeadline::Helpers

        deadline in: 1
        def self.perform
          sub_method_1
          sub_method_1
          method_never_called
        end

        deadline runs_for: 0.6
        def self.sub_method_1
          sleep 0.7
        end

        def self.method_never_called; end
      end
    end

    it 'raises an out of time error when' do
      expect do
        klass.perform
      end.to raise_error ExecutionDeadline::OutOfTime
    end

    it 'only calls sleep once' do
      expect(klass).to receive(:sleep).with(any_args).once.and_call_original
      begin
        klass.perform
      rescue ExecutionDeadline::DeadlineError
      end
    end
  end
  describe 'their usage on class methods' do
    let(:klass) do
      Class.new do
        extend ExecutionDeadline::Helpers

        deadline in: 1
        def self.perform
          sub_method_1
          sub_method_1
          method_never_called
        end

        deadline runs_for: 0.6
        def self.sub_method_1
          sleep 0.7
        end

        def self.method_never_called; end
      end
    end

    it 'raises an out of time error when' do
      expect do
        klass.perform
      end.to raise_error ExecutionDeadline::OutOfTime
    end

    it 'only calls sleep once' do
      expect(klass).to receive(:sleep).with(any_args).once.and_call_original
      begin
        klass.perform
      rescue ExecutionDeadline::DeadlineError
      end
    end
  end

  describe 'a method that thinks it is slow' do
    let(:klass) do
      Class.new do
        extend ExecutionDeadline::Helpers

        deadline in: 1
        def perform
          sub_method_1
          sub_method_1
          method_is_called
        end

        deadline runs_for: 0.6
        def sub_method_1
          sleep 0.1
        end

        def method_is_called
          :abcd
        end
      end
    end

    it 'returns the correct return value' do
      expect(instance.perform).to eq :abcd
    end
  end

  describe 'a slow method' do
    let(:klass) do
      Class.new do
        extend ExecutionDeadline::Helpers

        deadline in: 1
        def perform
          sub_method_1
          sub_method_1
          method_never_called
        end

        deadline runs_for: 0.6
        def sub_method_1
          sleep 0.7
        end

        def method_never_called; end
      end
    end

    it 'raises an out of time error when' do
      expect do
        instance.perform
      end.to raise_error ExecutionDeadline::OutOfTime
    end

    it 'only calls sleep once' do
      expect(instance).to receive(:sleep).with(any_args).once.and_call_original
      begin
        instance.perform
      rescue ExecutionDeadline::DeadlineError
      end
    end
  end
end
