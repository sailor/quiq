# Quiq

Quiq is a distributed task queue backed by Redis to process jobs in background.

It relies on asynchronous IOs to process multiple jobs simultaneously. The event loop is provided by the [Async](https://github.com/socketry/async) library and many other gems of the [Socketry](https://github.com/socketry) family.

It can be used without Rails, but will play nicely with [ActiveJob](https://guides.rubyonrails.org/active_job_basics.html) even though it's not supported officialy (more details [here](#activejob-support)).

The library is in a very early stage, it is **not suitable for production** yet.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'quiq'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install quiq

## Usage

To launch the workers, you can use the `quiq` command.

```
Usage: quiq [options]
    -p, --path PATH                  Location of the workers to load
    -q, --queues NAMES               Comma-separated list of queues to poll
    -l, --log-level LEVEL            The logging level
    -v, --version                    Output version and exit
    -h, --help                       Show this message
```

This is how to use it with a Rails application using [ActiveJob](https://guides.rubyonrails.org/active_job_basics.html)

    $ bundle exec quiq -p ./config/environment.rb -q critical,medium,low -l WARN

## Configuration

Here is an example of a configuration within a Rails application:

```ruby
Quiq.configure do |config|
  config.redis = 'redis://localhost:6379'
  config.logger = Rails.logger
end
```

### ActiveJob support

As there is no official support for Quiq in ActiveJob, you must monkey patch it to use it as you would do with any other background jobs system. You can find a complete example here: [testapp/config/initializers/quiq.rb](https://github.com/sailor/quiq/blob/master/testapp/config/initializers/quiq.rb)

```ruby
module ActiveJob
  module QueueAdapters
    class QuiqAdapter
      def enqueue(job)
        Quiq::Client.push(job)
      end

      def enqueue_at(job, timestamp)
        Quiq::Client.push(job, scheduled_at: timestamp)
      end

      class JobWrapper
        class << self
          def perform(job_data)
            Base.execute job_data
          end
        end
      end
    end
  end
end
```

## Jobs

As it is using the [Async](https://github.com/socketry/async) gem, we can use the many features provided by this library.

You can access the underlying `Async::Task` by using `Quiq.current_task`.

A very dumb example:

```ruby
class TestJob < ApplicationJob
  def perform(data, wait)
    puts "Receiving new job: #{data}"
    Quiq.current_task.sleep wait # Non blocking call
    puts "Time to wake up after #{wait} seconds"
  end
end
```

More interesting use case. If you combine `quiq` with the [async-http](https://github.com/socketry/async-http) gem, you'll be able to make asynchronous HTTP calls:

```ruby
require 'uri'
require 'async/http/internet'

class HttpJob < ApplicationJob
  def perform(url)
    uri = URI(url)

    client = Async::HTTP::Internet.new
    response = client.get(url)
    Quiq.logger.info response.read
  end
end
```

### Scheduled jobs

Since Quiq supports ActiveJob interface you can use the same approach to schedule jobs for the future.

```ruby
TestJob.set(wait: 5.seconds).perform_later(1, 2)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Benchmarks

To benchmark the system you can use the `quiqload` binary. To launch it, execute:

    $ time bin/quiqload -n 10_000 -w 1

```
Usage: quiqload [options]
    -n, --number JOBS                Number of jobs to enqueue
    -w, --wait DURATION              Idle time within each job (in seconds)
    -h, --help                       Show this message
```

## Todo

- [ ] Graceful shutdown
- [x] Customizable logger
- [x] Dead-letter queue
- [x] Scheduler
- [ ] Specs
- [x] Retry system
- [ ] Batches support
- [x] Load testing script
- [ ] Admin user interface
- [ ] Rate limiting capabilities

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sailor/quiq.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
