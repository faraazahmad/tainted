# frozen_string_literal: true

RSpec.describe Tainted do
  it "has a version number" do
    expect(Tainted::VERSION).not_to be nil
  end

  it "does something useful" do
    file = "#{__dir__}/../fixtures/simple.rb"
    lint = Tainted::Lint.new(file, %i[tainted], %i[unsafe])
    result = lint.analyze
    expect(result).to eq(
      [
        "Method `unsafe()` consuming tainted variable `d`",
        "Method `unsafe()` consuming tainted variable `c`"
      ]
    )
  end
end
