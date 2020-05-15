require 'timeout'

module ExecutionDeadline
  module Deadliner
    WRAPPED_METHOD = Proc.new do |options|
      Proc.new do |*args, **kwargs, &blk|
        set_deadline = options[:in]  && ExecutionDeadline.set_deadline(
          expires_at: Time.now + options[:in],
          raises: options[:raises]
        )

        current_deadline = ExecutionDeadline.current_deadline
        current_deadline&.require_seconds_left!(options[:runs_for]) if options[:runs_for]

        result = if !options[:interruptible]
          super(*args, **kwargs, &blk)
        else
          Timeout.timeout(current_deadline&.time_left) do
            super(*args, **kwargs, &blk)
          rescue => Timeout::Error
          end
        end

        current_deadline&.check_deadline_expiration!

        result
      ensure
        ExecutionDeadline.clear_deadline! if set_deadline
      end
    end

    def inspect
      "ExecutionDeadline::#{@_execution_deadline_built_for}Proxy"
    end

    def _execution_deadline_built_for
      @_execution_deadline_built_for
    end

    def _execution_deadline_built_for=(val)
      @_execution_deadline_built_for = val
    end

    def wrap_implementation(method_name, config)
      define_method(method_name, &WRAPPED_METHOD.call(config))
    end
  end
end
