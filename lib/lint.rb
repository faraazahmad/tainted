module Tainted
  class Lint
    def initialize(filepath, sources, sinks)
      @filepath = filepath
      @sources = sources
      @sinks = sinks

      t = Tainted::DataFlow.new(@filepath)
      t.generate
      var_dependencies = t.tainted
      State.instance.var_dependencies = var_dependencies

      @visitor = Static.new(var_dependencies, @sources, @sinks)
    end

    def analyze
      @visitor.visit(SyntaxTree.parse_file(@filepath))
    end
  end
end
