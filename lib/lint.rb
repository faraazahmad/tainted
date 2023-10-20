module Tainted
  class Lint
    def initialize(filepath)
      t = Tainted::DataFlow.new(filepath)
      t.generate
      var_dependencies = t.tainted
      State.instance.var_dependencies = var_dependencies

      visitor = Static.new(var_dependencies, %i[tainted], %i[unsafe])
      visitor.visit(SyntaxTree.parse_file(filepath))
    end
  end
end
