require "syntax_tree"

module Tainted
  class Static < SyntaxTree::Visitor
    def initialize(var_dependencies, sources, sinks)
      @sources = sources
    end

    def visit(node)
      nodes = node.child_nodes[0].child_nodes

      # First visit all assignments
      # mark tainted variables
      nodes
        .select { |child| child.is_a?(SyntaxTree::Assign) }
        .each { |child| parse_assign(child) }

      # Visit all call nodes
      # check if a tainted variable is passed to it
      nodes
        .select { |child| child.is_a?(SyntaxTree::CallNode) }
        .each { |child| parse_call(child) }
    end

    def parse_assign(node)
      variable_name = node.target.value.value
      return unless node.value.is_a?(SyntaxTree::CallNode)

      method_name = node.value.message.value
      if @sources.include?(method_name.to_sym)
        State.instance.var_dependencies[variable_name.to_sym][:tainted] = true
      end
    end

    def parse_call(node)
      arguments = node.arguments.arguments.parts

      taint_statuses = arguments.map do |arg| 
        [arg, taint_status(arg.value.value.to_sym)]
      end

      method_name = node.message.value
      taint_statuses.each do |status|
        if status[1]
          puts "Method `#{method_name}()` consuming tainted variable `#{status[0].value.value}`"
        end
      end
    end

    def taint_status(var)
      if State.instance.var_dependencies[var].key?(:tainted)
        return State.instance.var_dependencies[var][:tainted]
      end

      tainted = false
      unless State.instance.var_dependencies[var][:from].empty?
        State.instance.var_dependencies[var][:from].each do |from|
          tainted ||= taint_status(from)
        end
      end
      State.instance.var_dependencies[var][:tainted] = tainted
    end
  end
end
