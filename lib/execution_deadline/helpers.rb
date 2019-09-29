# frozen_string_literal: true

require 'execution_deadline/version'
require 'execution_deadline/deadline'

module ExecutionDeadline
  module Helpers
    def deadline(options = {})
      options[:in] ||
        options[:runs_for] ||
        raise('expected deadline to include either :in or :runs_for')

      @last_deadline_config = options
    end

    def method_added(method_name)
      return if @last_deadline_config.nil? || @last_deadline_config == {}

      options = @last_deadline_config
      @last_deadline_config = nil

      _add_deadlined_method(method_name, options)
    end

    private

    def _add_deadlined_method(method_name, options)
      aliased_method_name = "_#{method_name}_without_deadline".to_sym

      alias_method aliased_method_name, method_name

      define_method(method_name) do |*args, &blk|
        set_deadline = options[:in]  && ExecutionDeadline.set_deadline(
          expires_at: Time.now + options[:in]
        )

        if ExecutionDeadline.current_deadline && options[:runs_for]
          ExecutionDeadline.current_deadline.runs_for(method_name, options[:runs_for]) do
            send(aliased_method_name, *args, &blk)
          end
        else
          send(aliased_method_name, *args, &blk)
        end
      ensure
        ExecutionDeadline.clear_deadline! if set_deadline
      end
    end
  end
end
