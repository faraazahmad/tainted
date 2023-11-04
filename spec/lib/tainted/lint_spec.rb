# frozen_stirng_literal: true

RSpec.describe Tainted::Lint do
  context "Given a file with tainted sources and sinks" do
    it "returns a result listing the taint errors" do
      file = File.expand_path "#{__dir__}/../../fixtures/simple.rb"
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
end
