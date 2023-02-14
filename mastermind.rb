# frozen_string_literal: true

# Game: Mastermind

module CodePeg
  CODEPEGS = %w[yellow green red blue purple pink].freeze

  def self.info
    puts "Code pegs: #{CODEPEGS.join(' ')}"
    puts 'Syntax: space-separated words (e.g. color color color color)'
  end

  def get_codepegs(quantity, random = nil)
    if random
      CODEPEGS.sample(quantity)
    else
      gets.chomp.split(' ')
    end
  end

  def self.valid?(codepegs)
    codepegs.all? { |codepeg| CODEPEGS.include?(codepeg) }
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

class CodeBreaker
  include CodePeg

  attr_accessor :guess

  def initialize(name)
    @name = name
    @guess = nil
    @winner = false
  end
end

codemaker = CodeMaker.new('Computer')
codemaker.pattern = codemaker.get_codepegs(4, 'random')

codebreaker = CodeBreaker.new('Player')
CodePeg.info
puts
print 'Guess: '
codebreaker.guess = codebreaker.get_codepegs(4)
