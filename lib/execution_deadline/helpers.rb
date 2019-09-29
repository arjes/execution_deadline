# frozen_string_literal: true

require 'execution_deadline/version'
require 'execution_deadline/deadline'

module ExecutionDeadline
  module Helpers
    UNWRAPPED_METHOD_NAME_SUFFIX = "_without_deadline"
    WRAPPED_METHOD = Proc.new do |options|
      Proc.new do |*args, &blk|
        set_deadline = options[:in]  && ExecutionDeadline.set_deadline(
          expires_at: Time.now + options[:in]
        )

        if ExecutionDeadline.current_deadline && options[:runs_for]
          ExecutionDeadline.current_deadline.runs_for(options[:runs_for]) do
            send(options[:aliased_method_name], *args, &blk)
          end
        else
          send(options[:aliased_method_name], *args, &blk)
        end
      ensure
        ExecutionDeadline.clear_deadline! if set_deadline
      end
    end

    def deadline(options = {})
      options[:in] ||
        options[:runs_for] ||
        raise('expected deadline to include either :in or :runs_for')

      @last_deadline_config = options
    end

    def method_added(method_name)
      return super unless _has_deadline_config?

      options = _fetch_and_reset_deadline_config
      options[:aliased_method_name] ||= "_#{method_name}#{UNWRAPPED_METHOD_NAME_SUFFIX}".to_sym

      alias_method options[:aliased_method_name], method_name

      define_method(method_name, &WRAPPED_METHOD.call(options))
    end

    def singleton_method_added(method_name)
      return super unless _has_deadline_config?

      options = _fetch_and_reset_deadline_config

      options[:aliased_method_name] ||= "_#{method_name}#{UNWRAPPED_METHOD_NAME_SUFFIX}".to_sym

      singleton_class.class_eval do
        alias_method options[:aliased_method_name], method_name
      end

      define_singleton_method(method_name, &WRAPPED_METHOD.call(options))
    end

    private

    def _has_deadline_config?
      !(@last_deadline_config.nil? || @last_deadline_config == {})
    end

    def _fetch_and_reset_deadline_config
      @last_deadline_config.tap { @last_deadline_config = nil }
    end

    def _add_deadlined_method(method_name, options)
    end

  end
end
