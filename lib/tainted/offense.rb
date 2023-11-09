# frozen_string_literal: true

module Tainted
  class Offense
    attr_reader :node, :message

    def initialize(node, message)
      @node = node
      @message = message
    end
  end
end
