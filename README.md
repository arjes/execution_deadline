# ExecutionDeadline

Odds are, you should never ever, ever, use Ruby's built in timeout module
unless you are 100% certain the wrapped code may be interrupted at any point.
This gem provides a way to easily identify safe breakpoints for timeout
operations.

Usage of this gem should be combined with [the-ultimate-guide-to-ruby-timeouts](https://github.com/ankane/the-ultimate-guide-to-ruby-timeouts)
to ensure your application releases resources from otherwise stuck threads.

## Why use deadlines?
[gRPC and Deadlines](https://grpc.io/blog/deadlines/)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'execution_deadline'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install execution_deadline

## Usage

### TL;DR;

```ruby
class Someclass
  extend ExecutionDeadline

  deadline in_seconds: 2 # or 2.seconds if using active support
  def potentially_slow_method
    # This method will be terminated at a safe location if it exceeds the
    # deadline of 2 seconds.

    method_expected_to_take_half_second # up to half a second consumed

  end

  deadline runs_for: 0.5
  def method_expected_to_take_half_second
    # Method are never interrupted mid execution.
    #
    # Since this method is expected to run for half a second ExecutionDeadline
    # performs two tasks:
    #   1) The method will not run, and an ExecutionDeadline::OutOfTime is
    #      raised if there is less than 0.5 left in the deadline
    #   2) An ExecutionDeadline::DeadlineExceeded exception is raised if the
    #      method comples and has passed the deadline
  end

end
```

### Deadline Enforcement

Deadlines are enforced only at breakpoints in the code specifically marked as
safe to error. This is most easily done with the simple method wrappers
provided in ExecutionDeadline::Helpers.

#### Examples

```ruby
class SlowClass
  extend ExecutionDeadline::Helpers

  deadline in: 1
  def perform
    sub_method_1
    sub_method_1
    method_never_called
  end

  deadline runs_for: 0.6
  def sub_method_1
    sleep 0.7
  end

  def method_never_called; end
end

instance = SlowClass.new
instance.perform # Throws OutOfTime error since sub_method_1 takes 0.6s of
                 # the total allowed 1s execution time. Since only 0.4s
                 # is left, the second execution of sub_method_1 is prevented
```

When calculating time left after the execution of a method the actual execution
time of the method is used. Consider the above example, but with a shorter
actual execution time.

```ruby
class ThinksItsSlowClass
  extend ExecutionDeadline::Helpers

  deadline in: 1
  def perform
    sub_method_1
    sub_method_1
    method_never_called
  end

  deadline runs_for: 0.6
  def sub_method_1
    sleep 0.1
  end

  def method_is_called
    :abcd
  end
end

instance = SlowClass.new
instance.perform # No errors are thrown and :abcd returned. Even though
                 # sub_method_1 says it will take 0.6 seconds, it actually
                 # takes 0.1 seconds. The second execution of sub_method_1 is
                 # checked against the remaining 0.9s, and allowed to continue
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/execution_deadline. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ExecutionDeadline project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/execution_deadline/blob/master/CODE_OF_CONDUCT.md).
