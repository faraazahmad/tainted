module Tainted
  class DataFlow
    def initialize(file_path)
      @file_path = file_path
      @cfg = nil
      @dfg = nil
      @iseq = nil
      @var_flows = {}
    end

    def generate
      @iseq = RubyVM::InstructionSequence.compile_file(@file_path)
      @iseq = SyntaxTree::YARV::InstructionSequence.from(@iseq.to_a)
      @cfg = SyntaxTree::YARV::ControlFlowGraph.compile(@iseq)
      @dfg = SyntaxTree::YARV::DataFlowGraph.compile(@cfg)
    end

    def tainted
      @dfg.insn_flows.keys.each do |key|
        flow = @dfg.insn_flows[key]
        next if flow.in.empty? && flow.out.empty?

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
              @var_flows[variable.name] = { from: [] }
            end
            @var_flows[variable.name][:from] = [
              *@var_flows[variable.name][:from],
              *trace_flows(flow)
            ]
          end
        end
      end

      @var_flows
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
        unless incoming_flow.is_a?(
                 SyntaxTree::YARV::DataFlowGraph::LocalArgument
               )
          next
        end

        from = [
          *from,
          incoming_flow,
          *trace_flows(@dfg.insn_flows[incoming_flow.length])
        ]
      end

      return from.map { |in_flow| var_from_insn(in_flow) }.reject(&:nil?)
    end

    def is_local?(insn)
      [
        SyntaxTree::YARV::GetLocalWC0,
        SyntaxTree::YARV::GetLocalWC1,
        SyntaxTree::YARV::GetLocal,
        SyntaxTree::YARV::SetLocalWC0,
        SyntaxTree::YARV::SetLocalWC1,
        SyntaxTree::YARV::SetLocal
      ].include?(insn.class)
    end
  end
end
