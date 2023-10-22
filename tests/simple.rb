require_relative '../lib/tainted'

file = "#{__dir__}/../fixtures/simple.rb"
lint = Tainted::Lint.new(file, %i[tainted], %i[unsafe])
lint.analyze