# frozen_string_literal: true

require 'execution_deadline/version'
require 'execution_deadline/helpers'

module ExecutionDeadline
  def self.current_deadline
    Thread.current[:deadline]
  end

  def self.clear_deadline!
    Thread.current[:deadline] = nil
  end

  # @param expires_at [Time] The time at which to set the current deadline to
  #   expire
  # @return [Boolean|Deadline] returns false if a deadline is already set, and
  #   returns a deadline object if it was successfully set
  def self.set_deadline(expires_at:)
    !current_deadline &&
      Thread.current[:deadline] = Deadline.new(expires_at: expires_at)
  end
end
