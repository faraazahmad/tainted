require_relative '../lib/tainted'
require_relative '../lib/static'
require_relative '../lib/lint'
require_relative '../lib/state'

file = "#{__dir__}/../fixtures/simple.rb"
Tainted::Lint.new(file)