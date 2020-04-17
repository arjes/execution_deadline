# frozen_string_literal: true

require 'execution_deadline/version'
require 'execution_deadline/deadline'
require 'execution_deadline/method_proxy'

module ExecutionDeadline
  module Helpers
    def deadline(options = {})
      options[:in] ||
        options[:runs_for] ||
        raise('expected deadline to include either :in or :runs_for')

      @last_deadline_config = options
    end

    def method_added(method_name)
      return super unless _has_deadline_config?

      ExecutionDeadline::MethodProxy
        .for_class(self)
        .wrap_implementation(method_name, _fetch_and_reset_deadline_config)
    end

    def singleton_method_added(method_name)
      return super unless _has_deadline_config?

      ExecutionDeadline::MethodProxy
        .for_class(singleton_class)
        .wrap_implementation(method_name, _fetch_and_reset_deadline_config)
    end

    private

    def _has_deadline_config?
      !(@last_deadline_config.nil? || @last_deadline_config == {})
    end

    def _fetch_and_reset_deadline_config
      @last_deadline_config.tap { @last_deadline_config = nil }
    end
  end
end
