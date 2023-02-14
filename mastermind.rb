# frozen_string_literal: true

# Game: Mastermind

module CodePeg
  CODEPEGS = %w[yellow green red blue purple pink].freeze

  def self.info
    puts "Code pegs: #{CODEPEGS.join(' ')}"
    puts 'Syntax: space-separated words'
    puts '        (e.g. color color color color)'
    puts
  end

  def get_codepegs(quantity, random = nil)
    if random
      selected_codepegs = []
      quantity.times { selected_codepegs << CODEPEGS.sample }
      selected_codepegs
    else
      gets.chomp.split(' ')
    end
  end

  def self.valid_color?(codepegs)
    codepegs.all? { |codepeg| CODEPEGS.include?(codepeg) }
  end
end

class Game
  include CodePeg

  attr_accessor :codemaker, :codebreaker

  attr_reader :rows, :spaces

  def initialize(rows, spaces)
    @rows = rows
    @spaces = spaces
    @codemaker = nil
    @codebreaker = nil
  end

  def rules
    puts 'Rules: Duplicated colors are ALLOWED.'
    puts '       Blank spaces are NOT ALLOWED.'
    puts '       You must fill each space with one color (code peg).'
    puts
  end

  def info
    puts "Number of rows (turns): #{@rows}"
    puts "Number of spaces per row: #{@spaces}"
    puts
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

  def valid_guess?
    CodePeg.valid_color?(@codebreaker.guess) &&
      @codebreaker.guess.length == @spaces
  end

  def invalid_guess
    puts
    puts "Couldn't get your guess."
    puts "You must type #{@spaces} colors from the code pegs (space-separated)."
  end

  def codebreaker_won?
    @codebreaker.winner = true if @codebreaker.guess == @codemaker.pattern
  end

  def winner
    puts
    puts @codebreaker.winner ? 'You won! You got it right.' :
      "Game over. The pattern was: #{@codemaker.pattern.join(' ')}"
  end
end

class CodeMaker
  include CodePeg

  attr_accessor :pattern, :winner

  def initialize(name)
    @name = name
    @pattern = []
    @winner = false
  end
end

class CodeBreaker
  include CodePeg

  attr_accessor :guess, :winner

  def initialize(name)
    @name = name
    @guess = []
    @winner = false
  end
end

# Start game with number of (rows, spaces)
game = Game.new(12, 4)

# Display documentation
puts 'GAME: MASTERMIND'
puts
game.rules
CodePeg.info
game.info

game.get_players
game.make_pattern

# Loop through Game rows making guesses
game.rows.times do |number|
  row = number + 1
  last_row = game.rows
  print "[Row #{row}] "
  game.make_guess

  if game.valid_guess?
    if game.codebreaker_won? || row == last_row
      game.winner # Display game winner
      break
    end
  else
    game.invalid_guess
    break
  end
end
