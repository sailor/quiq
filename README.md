# Quiq

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/quiq`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

    $ bundle exec quiq -p ./config/environment.rb

## Configuration

Here is an example of a configuration within a Rails application:

```ruby
Quiq.configure do |config|
  config.redis = 'redis://localhost:6379'
  config.logger = Rails.logger
end
```

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Benchmarks

To benchmark the system you can use the `quiqload` binary. To launch it, execute:

    $ time RUBYOPT="-W0" bin/quiqload -n 10_000 -w wait 1

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
- [ ] Scheduler
- [ ] Specs
- [ ] Retry system
- [ ] Batches support
- [x] Load testing script
- [ ] Admin user interface

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sailor/quiq.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
