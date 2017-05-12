# Shift::Api::Core

Welcome to Shift API Core - the core gem for all api access gems for the shift
commerce platform.

## Installation

Generally, as this gem is to be used by another gem and not directly, you should
add

```ruby
spec.add_runtime_dependency "shift-api-core"
```

to your gem's gemspec file

## Usage

The gem depending on this gem will generally define models to access a
shift commerce service.

A model simply looks like this :-

```ruby
module ShiftCommerce
  module Inventory
    class StockLevel < ::Shift::Api::Core::Model

    end
  end
end

```

This model can then be used in a similar (but not the same !) manner as an
active record model.

For example,

```ruby
ShiftCommerce::Inventory::StockLevel.find(1)
```

will request a "StockLevel" with an id of 1

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shiftcommerce/shift-api-core-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
