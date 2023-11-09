# frozen_string_literal: true

module Tainted
  class Static < SyntaxTree::Visitor
    attr_reader :offenses

    def initialize(sources, sinks)
      super()

      @sources = sources
      @sinks = sinks
      @offenses = []
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

      method_name =
        case node.value
        when SyntaxTree::CallNode
          node.value.message.value
        when SyntaxTree::ARef
          # (aref (vcall (ident "<method_name>")))
          node.value.collection.value.value
        end

      return if method_name.nil?
      return unless @sources.include?(method_name&.to_sym)

      State.instance.var_dependencies[variable_name.to_sym][:tainted] = true
    end

    def parse_call(node)
      arguments = node.arguments.arguments.parts

      taint_statuses =
        arguments.map { |arg| [arg, taint_status(arg.value.value.to_sym)] }

      method_name = node.message.value
      return unless @sinks.include?(method_name.to_sym)

      taint_statuses.each do |status|
        next unless status[1]

        @offenses << Offense.new(node, "Method `#{method_name}()` consuming tainted variable `#{status[0].value.value}`")
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
