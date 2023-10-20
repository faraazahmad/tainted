require_relative '../lib/tainted'

t = Tainted.new("#{__dir__}/../fixtures/gets.rb")
t.generate
t.tainted