# frozen_string_literal: true

require 'execution_deadline/errors'

module ExecutionDeadline
  class Deadline
    def initialize(expires_at:, raises: nil)
      @expires_at = expires_at
      @raises = raises
    end

    def require_seconds_left!(seconds_left)
      time_left < seconds_left &&
        raise(
          @raises || OutOfTime,
          "Unable to run method expected run time #{seconds_left} " \
          "but only #{time_left}s left"
        )
    end

    def check_deadline_expiration!
      expired? && raise(@raises || DeadlineExceeded)
    end

    def time_left
      @expires_at - Time.now
    end

    def expired?
      @expires_at <= Time.now
    end
  end
end
