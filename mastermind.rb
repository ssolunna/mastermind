# frozen_string_literal: true

# Game: Mastermind

module CodePeg
  CODEPEGS = %w[yellow green red blue purple pink].freeze

  def self.info
    puts "Code pegs: #{CODEPEGS.join(' ')}"
    puts 'Syntax: lowercase and space-separated words'
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

module KeyPeg
  def self.info
    puts 'Key pegs: colored, white'
    puts 'Colored pegs = Code peg is correct in both color and position'
    puts 'White pegs = Code peg is correct in color but in the wrong position'
    puts
  end

  def self.count(pattern, guess)
    pattern = pattern.rotate(0) # Makes a copy of pattern array
    guess = guess.rotate(0) # Makes a copy of guess array
    colored = 0
    white = 0

    pattern.each_with_index do |codepeg, slot|
      if codepeg == guess[slot]
        colored += 1
      elsif guess.include?(codepeg)
        white += 1
        guess.fill('x', guess.index(codepeg), 1)
      end
    end

    { colored: colored, white: white }
  end

  def self.feedback(pattern, guess)
    result = count(pattern, guess)

    short_feedback(result)

    if result.all? { |_keypeg, quantity| quantity.zero? }
      puts 'No color found in pattern.'
    else
      print 'You got: '
      i = 0
      result.each do |keypeg, quantity|
        if quantity.positive?
          print ', ' if i >= 1
          i += 1
          print "#{quantity} #{keypeg} peg#{'s' if quantity > 1}"
        end
      end
      puts '.'
    end
  end

  def self.short_feedback(result)
    print "["
    result.each { |keypeg, quantity| print quantity, keypeg[0].upcase }
    print '] '
  end
end

class Game
  include CodePeg

  attr_accessor :codemaker, :codebreaker

  attr_reader :rows, :slots

  def initialize(rows, slots)
    @rows = rows
    @slots = slots
    @codemaker = nil
    @codebreaker = nil
  end

  def rules
    puts 'Rules: Duplicated colors are ALLOWED.'
    puts '       Blank slots are NOT ALLOWED.'
    puts '       You must fill each slot with one color (code peg).'
    puts
  end

  def info
    puts "Number of rows (turns): #{@rows}"
    puts "Number of slots per row: #{@slots}"
    puts
  end

  def get_players
    @codemaker = CodeMaker.new('Computer')
    @codebreaker = CodeBreaker.new('Player')
  end

  def make_pattern
    @codemaker.pattern = @codemaker.get_codepegs(@slots, 'random')
  end

  def make_guess
    print 'Guess: '
    @codebreaker.guess = @codebreaker.get_codepegs(@slots)
  end

  def valid_guess?
    CodePeg.valid_color?(@codebreaker.guess) &&
      @codebreaker.guess.length == @slots
  end

  def invalid_guess
    puts
    puts "Couldn't get your guess."
    puts "You must type #{@slots} colors from the code pegs (space-separated)."
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

# Start game with number of (rows, slots)
game = Game.new(12, 4)

# Display documentation
puts 'GAME: MASTERMIND'
puts
game.rules
CodePeg.info
KeyPeg.info
game.info

game.get_players
game.make_pattern

# Loop through Game rows making guesses
game.rows.times do |number|
  row = number + 1
  last_row = game.rows
  puts
  print "[Row #{row}] "
  game.make_guess

  if game.valid_guess?
    KeyPeg.feedback(game.codemaker.pattern, game.codebreaker.guess)
    if game.codebreaker_won? || row == last_row
      game.winner # Display game winner
      break
    end
  else
    game.invalid_guess
    break
  end
end
