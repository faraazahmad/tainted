require 'syntax_tree'

class Tainted
  def initialize(file_path)
    @file_path = file_path 
    @cfg = nil
    @dfg = nil
    @iseq = nil
    @var_flows = {}
  end

  # private
  
  def generate
    @iseq = RubyVM::InstructionSequence.compile_file(@file_path)
    @iseq = SyntaxTree::YARV::InstructionSequence.from(@iseq.to_a)
    @cfg = SyntaxTree::YARV::ControlFlowGraph.compile(@iseq)
    @dfg = SyntaxTree::YARV::DataFlowGraph.compile(@cfg)
    # binding.irb
  end

  def tainted
    @dfg.insn_flows.keys.each do |key|
      flow = @dfg.insn_flows[key]
      next if flow.in.empty? && flow.out.empty?

      # Check in
      # next if flow.in.empty?
      # unless flow.in.empty?
      #   # in_flow = flow.in[0]
      #   flow.in.each do |in_flow|
      #     insn = @cfg.insns[in_flow.length]

      #     variable = nil
      #     if insn.is_a?(SyntaxTree::YARV::GetLocalWC0)
      #       variable = @iseq.local_table.locals[insn.index]
      #     end
      #     next if variable.nil?

      #     # pp [flow, variable]
      #     if @var_flows.key? variable.name
      #       @var_flows[variable.name][:to] << flow
      #     else
      #       @var_flows[variable.name] = { to: [flow], from: [] }
      #     end
      #   end
      # end

      # Check out
      unless flow.out.empty?
        flow.out.each do |out_flow|
          insn = @cfg.insns[out_flow.length]

          variable = nil
          if insn.is_a?(SyntaxTree::YARV::SetLocalWC0)
            variable = @iseq.local_table.locals[insn.index]
          end
          next if variable.nil?

          unless @var_flows.key?(variable.name)
            @var_flows[variable.name] = { from: [], to: [] }
          end
          @var_flows[variable.name][:from] = [*@var_flows[variable.name][:from], *trace_flows(flow)]
        end
      end
    end
  end

  def var_from_insn(flow)
    return flow if flow.is_a? Symbol

    insn = @cfg.insns[flow.length]
    return unless is_local?(insn)

    @iseq.local_table.locals[insn.index].name
  end

  def trace_flows(flow)
    from = []

    flow.in.each do |incoming_flow|
      next unless incoming_flow.is_a?(SyntaxTree::YARV::DataFlowGraph::LocalArgument)

      from = [
        *from,
        incoming_flow,
        *trace_flows(@dfg.insn_flows[incoming_flow.length])
      ]
    end

    return from.map { |in_flow| var_from_insn(in_flow) }.reject(&:nil?)
  end

  def is_local?(insn)
    classes = [
      SyntaxTree::YARV::GetLocalWC0,
      SyntaxTree::YARV::GetLocalWC1,
      SyntaxTree::YARV::GetLocal,
      SyntaxTree::YARV::SetLocalWC0,
      SyntaxTree::YARV::SetLocalWC1,
      SyntaxTree::YARV::SetLocal,
    ]

    return classes.include?(insn.class)
  end
end
