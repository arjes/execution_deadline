# frozen_string_literal: true

require 'pry'
require 'spec_helper'

RSpec.describe 'deadline declaration' do
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
