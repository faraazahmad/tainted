# frozen_string_literal: true

module Tainted
  class Lint
    def initialize(filepath, sources, sinks)
      @filepath = filepath

      t = DataFlow.new(@filepath)
      t.generate
      var_dependencies = t.tainted
      State.instance.var_dependencies = var_dependencies

      @visitor = Static.new(sources, sinks)
    end

    def analyze
      @visitor.visit(SyntaxTree.parse_file(@filepath))
      @visitor.offenses
    end
  end
end
