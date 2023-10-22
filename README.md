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
# Method `unsafe()` consuming tainted variable `d`
# Method `unsafe()` consuming tainted variable `c`
```
