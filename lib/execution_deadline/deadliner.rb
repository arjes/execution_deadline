module ExecutionDeadline
  module Deadliner
    WRAPPED_METHOD = Proc.new do |options|
      Proc.new do |*args, **kwargs, &blk|
        set_deadline = options[:in]  && ExecutionDeadline.set_deadline(
          expires_at: Time.now + options[:in],
          raises: options[:raises]
        )

        ExecutionDeadline.current_deadline&.require_seconds_left!(options[:runs_for]) if options[:runs_for]
        super(*args, **kwargs, &blk).tap do
          ExecutionDeadline.current_deadline&.check_deadline_expiration!
        end
      ensure
        ExecutionDeadline.clear_deadline! if set_deadline
      end
    end

    def inspect
      "ExecutionDeadline::#{@_exuection_deadline_built_for}Proxy"
    end

    def _exuection_deadline_built_for
      @_exuection_deadline_built_for
    end

    def _exuection_deadline_built_for=(val)
      @_exuection_deadline_built_for = val
    end

    def wrap_implementation(method_name, config)
      define_method(method_name, &WRAPPED_METHOD.call(config))
    end
  end
end
