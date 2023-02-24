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

  def get_codepegs(qty, random = nil)
    if random
      selected_codepegs = []
      qty.times { selected_codepegs << CODEPEGS.sample }
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

  def self.print_feedback(result)
    print_short_feedback(result)

    if result.all? { |_keypeg, qty| qty.zero? }
      puts 'No color found in pattern.'
    else
      print 'Key pegs awarded: '
      i = 0
      result.each do |keypeg, qty|
        next unless qty.positive?

        print ', ' if i >= 1
        i += 1
        print "#{qty} #{keypeg} peg#{'s' if qty > 1}"
      end
      puts '.'
    end
  end

  def self.print_short_feedback(result)
    print '['
    result.each { |keypeg, qty| print qty, keypeg[0].upcase }
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
    print_rules
    CodePeg.info
    KeyPeg.info
    puts "Number of rows (turns): #{@rows}"
    puts "Number of slots per row: #{@slots}"
    puts
  end

  def play
    @codemaker.player.make_pattern(@slots)

    unless valid?(@codemaker.pattern)
      print_invalid(@codemaker.pattern)
      return
    end

    @rows.times do |num|
      current_row = num + 1
      puts
      print "[Row #{current_row}] Guess: "
      @codebreaker.player.make_guess(@slots)

      if valid?(@codebreaker.guess)
        @codebreaker.feedback =
          KeyPeg.count(@codemaker.pattern, @codebreaker.guess)
        KeyPeg.print_feedback(@codebreaker.feedback)

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
      puts "Right guess. #{@codebreaker.player.class} (codebreaker) wins!"
    else
      puts "Game over. #{@codemaker.player.class} (codemaker) wins!"
    end
  end
end

class CodeMaker
  attr_accessor :pattern, :winner
  attr_reader :player

  def initialize(player)
    @player = player.new(self)
    @pattern = []
    @winner = false
  end
end

class CodeBreaker
  attr_accessor :guess, :feedback, :winner
  attr_reader :player

  def initialize(player)
    @player = player.new(self)
    @guess = []
    @feedback = {}
    @winner = false
  end
end

class ComputerPlayer
  include CodePeg

  def initialize(role)
    @role = role
    @guesses = []
    @correct_codepegs = []
    @selected_codepegs = []
  end

  def make_pattern(qty)
    @role.pattern = get_codepegs(qty, 'random')
  end

  def make_guess(qty)
    current_keypegs = @role.feedback.values.sum

    @role.guess =
      if @role.guess.empty?
        random_color_in_all_slots(qty)
      elsif current_keypegs.zero?
        all_slots_same_color(qty)
      elsif current_keypegs < qty
        keep_same_color(current_keypegs)
      else
        change_pegs_positions
      end

    @guesses << @role.guess
    puts @role.guess.join(' ')
    @role.guess
  end

  def random_color_in_all_slots(qty)
    guess = []
    random_color = CODEPEGS.sample
    qty.times { guess << random_color }
    guess
  end

  def all_slots_same_color(qty)
    CODEPEGS.each do |codepeg|
      guess = Array.new(qty, codepeg)
      return guess unless @guesses.include?(guess)
    end
  end

  def keep_same_color(qty)
    guess = [*@correct_codepegs]

    unless qty == @correct_codepegs.length
      correct_codepeg = @role.guess.last

      (qty - @correct_codepegs.length).times do
        guess << correct_codepeg
      end

      @selected_codepegs << correct_codepeg
      @correct_codepegs = guess.rotate(0) # Makes a copy of guess
    end

    guess.concat(non_selected_codepeg(@role.guess.length - qty))
  end

  def non_selected_codepeg(qty)
    non_selected = []

    CODEPEGS.each do |codepeg|
      next if @selected_codepegs.include?(codepeg)

      qty.times { non_selected << codepeg }
      @selected_codepegs << codepeg
      break
    end

    non_selected
  end

  def change_pegs_positions
    @role.guess.shuffle
  end
end

class HumanPlayer
  include CodePeg

  def initialize(role)
    @role = role
  end

  def make_pattern(qty)
    print 'Pattern: '
    @role.pattern = get_codepegs(qty)
  end

  def make_guess(qty)
    @role.guess = get_codepegs(qty)
  end
end

puts 'GAME: MASTERMIND'
puts

# Allow HumanPlayer to choose between being the code maker or the code breaker
print 'Do you want to be the code maker? [y|N]: '
response = gets.chomp
puts

case response.downcase
when 'y', 'yes'
  # Start game with (codemaker, codebreaker, rows, slots per row)
  Game.new(HumanPlayer, ComputerPlayer, 12, 4).play
when 'n', 'no', ''
  Game.new(ComputerPlayer, HumanPlayer, 12, 4).play
else
  puts 'Error: Unknown answer.'
end
