# frozen_string_literal: true

module ExecutionDeadline
  class DeadlineError < StandardError; end
  class OutOfTime < DeadlineError; end
  class DeadlineExceeded < DeadlineError; end
end
