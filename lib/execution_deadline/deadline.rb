# frozen_string_literal: true

require 'execution_deadline/errors'

module ExecutionDeadline
  class Deadline
    def initialize(expires_at:)
      @expires_at = expires_at
    end

    def runs_for(method_name, duration)
      time_left < duration &&
        raise(
          OutOfTime,
          "Unable to run method #{method_name}, " \
          "expected run time #{duration} but only #{time_left}s left"
        )

      yield.tap do
        expired? && raise(DeadlineExceeded, "Deadline exceeded after #{method_name}")
      end
    end

    def time_left
      @expires_at - Time.now
    end

    def expired?
      @expires_at <= Time.now
    end
  end
end
