# tainted

A gem for taint-checking your Ruby code.

## Installation

```sh
gem install tainted
```

## Usage

```ruby
# fixtures/simple.rb

a = tainted()
b = a + 1
c = b + 2
d = b + c
unsafe(d)
unsafe(c)
```

```ruby
# test.rb

require 'tainted'

file = "#{__dir__}/../fixtures/simple.rb"
lint = Tainted::Lint.new(file, %i[tainted], %i[unsafe])
lint.analyze
=>
[#<Tainted::Offense:0x0000000107caf690
  @message="Method `unsafe()` consuming tainted variable `d`",
  @node=(call nil nil (ident "unsafe") (arg_paren (args ((var_ref (ident "d"))))))>,
 #<Tainted::Offense:0x0000000107caf5f0
  @message="Method `unsafe()` consuming tainted variable `c`",
  @node=(call nil nil (ident "unsafe") (arg_paren (args ((var_ref (ident "c"))))))>]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/faraazahmad/tainted. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/faraazahmad/tainted/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone is expected to follow the [code of conduct](https://github.com/faraazahmad/tainted/blob/main/CODE_OF_CONDUCT.md).
