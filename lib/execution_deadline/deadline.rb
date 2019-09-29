# frozen_string_literal: true

require 'execution_deadline/errors'

module ExecutionDeadline
  class Deadline
    def initialize(expires_at:)
      @expires_at = expires_at
    end

    def runs_for(duration)
      time_left < duration &&
        raise(
          OutOfTime,
          "Unable to run method expected run time #{duration} " \
          "but only #{time_left}s left"
        )

      yield.tap do
        expired? && raise(DeadlineExceeded)
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
