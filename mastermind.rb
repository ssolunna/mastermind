# frozen_string_literal: true

# Game: Mastermind

class Game
  attr_accessor :codemaker, :codebreaker
  attr_reader :rows

  def initialize(rows, spaces)
    @rows = rows
    @spaces = spaces
    @codemaker = nil
    @codebreaker = nil
  end

  def get_players
    @codemaker = CodeMaker.new('Computer')
    @codebreaker = CodeBreaker.new('Player')
  end

  def make_pattern
    @codemaker.pattern = @codemaker.get_codepegs(@spaces, 'random')
  end

  def make_guess
    print 'Guess: '
    @codebreaker.guess = @codebreaker.get_codepegs(@spaces)
  end

  def valid?(codepegs)
    CodePeg.valid_color?(codepegs) && codepegs.length == @spaces
  end
end

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

  def self.valid_color?(codepegs)
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

# Display documentation
CodePeg.info
puts

# Start game with number of (rows, spaces)
game = Game.new(12, 4)
game.get_players
game.make_pattern

game.rows.times do |number|
  row = number + 1
  print "[Row #{row}] "
  game.make_guess
end
