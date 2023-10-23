# frozen_string_literal: true

require "singleton"

class State
  include Singleton
  attr_accessor :var_dependencies
end
