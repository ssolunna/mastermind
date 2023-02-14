# frozen_string_literal: true

# Game: Mastermind

module CodePeg
  CODEPEGS = %w[yellow green red blue purple pink].freeze

  def get_codepegs(quantity)
    selected_codepegs = CODEPEGS.sample(quantity)
  end
end

class CodeMaker
  include CodePeg

  attr_accessor :pattern

  def initialize(name)
    @name = name
    @pattern = nil
    @winner = false
  end
end

codemaker = CodeMaker.new('computer')
codemaker.pattern = codemaker.get_codepegs(4)
