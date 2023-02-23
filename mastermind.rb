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
        next unless quantity.positive?

        print ', ' if i >= 1
        i += 1
        print "#{quantity} #{keypeg} peg#{'s' if quantity > 1}"
      end
      puts '.'
    end
  end

  def self.short_feedback(result)
    print '['
    result.each { |keypeg, quantity| print quantity, keypeg[0].upcase }
    print '] '
  end
end

class Game
  include CodePeg
  include KeyPeg

  attr_accessor :codemaker, :codebreaker

  attr_reader :rows, :slots

  def initialize(codemaker, codebreaker, rows, slots)
    @rows = rows
    @slots = slots
    @codemaker = CodeMaker.new(codemaker)
    @codebreaker = CodeBreaker.new(codebreaker)
    print_info
  end

  def print_rules
    puts 'Rules: Duplicated colors are ALLOWED.'
    puts '       Blank slots are NOT ALLOWED.'
    puts '       You must fill each slot with one color (code peg).'
    puts
  end

  def print_info
    puts 'GAME: MASTERMIND'
    puts
    print_rules
    CodePeg.info
    KeyPeg.info
    puts "Number of rows (turns): #{@rows}"
    puts "Number of slots per row: #{@slots}"
    puts
  end

  def play
    @codemaker.pattern = make_pattern
    unless valid?(@codemaker.pattern)
      print_invalid(@codemaker.pattern)
      return
    end

    @rows.times do |num|
      current_row = num + 1
      puts
      print "[Row #{current_row}] Guess: "
      @codebreaker.guess = make_guess
      puts @codebreaker.guess.join(' ') if @codebreaker.player == 'ComputerPlayer'

      if valid?(@codebreaker.guess)
        KeyPeg.feedback(@codemaker.pattern, @codebreaker.guess)
        if codebreaker_won? || current_row == @rows
          puts
          print_winner
          break
        end
      else
        print_invalid(@codebreaker.guess)
        break
      end
    end
  end

  def make_pattern
    print 'Pattern: ' if @codemaker.player == 'HumanPlayer'

    if @codemaker.player == 'ComputerPlayer'
      @codemaker.get_codepegs(@slots, 'random')
    else
      @codemaker.get_codepegs(@slots)
    end
  end

  def make_guess
    if @codebreaker.player == 'HumanPlayer'
      @codebreaker.get_codepegs(@slots)
    else
      @codebreaker.get_codepegs(@slots, 'random')
    end
  end

  def valid?(codepegs)
    CodePeg.valid_color?(codepegs) && codepegs.length == @slots
  end

  def print_invalid(codepegs)
    case codepegs
    when @codemaker.pattern
      puts "Couldn't get your pattern."
    when @codebreaker.guess
      puts "Couldn't get your guess."
    end

    puts
    puts "You must type #{@slots} colors from the code pegs."
    puts '(lowercase and space-separated words)'
  end

  def codebreaker_won?
    @codebreaker.winner = true if @codebreaker.guess == @codemaker.pattern
  end

  def print_winner
    if @codebreaker.winner
      puts "Right guess. #{@codebreaker.player} (codebreaker) wins!"
    else
      puts "Game over. #{@codemaker.player} (codemaker) wins!"
    end
  end
end

class CodeMaker
  include CodePeg

  attr_accessor :pattern, :winner
  attr_reader :player

  def initialize(player)
    @player = player
    @pattern = []
    @winner = false
  end
end

class CodeBreaker
  include CodePeg

  attr_accessor :guess, :winner
  attr_reader :player

  def initialize(player)
    @player = player
    @guess = []
    @winner = false
  end
end

# Allow HumanPlayer to choose between being the code maker or the code breaker
print 'Do you want to be the code maker? [y|N]: '
response = gets.chomp
puts

case response.downcase
when 'y', 'yes'
  # Start game with (codemaker, codebreaker, rows, slots per row)
  Game.new('HumanPlayer', 'ComputerPlayer', 12, 4).play
when 'n', 'no', ''
  Game.new('ComputerPlayer', 'HumanPlayer', 12, 4).play
else
  puts 'Error: Unknown answer.'
end
