class Hangman
  TURNS = 8

  attr_reader :guesser, :referee, :board

  def initialize(players)
    @guesser = players[:guesser]
    @referee = players[:referee]
    @guesses_left = TURNS
    @already_guessed = []
  end

  def play
    setup

    until @guesses_left == 0
      render_game(board)
      puts "\nGuesses Remaining: #{@guesses_left}"
      take_turn

      if game_won?
        puts "Secret Word >> #{referee.require_secret}"
        puts "You guessed the word correctly!"
        return
      end
    end

    puts "The word was #{referee.require_secret}."
    puts "The guesser has lost!"
    nil
  end

  def setup
    secret_length = referee.pick_secret_word
    guesser.register_secret_length(secret_length)
    @board = [nil] * secret_length
    #^This is neat, I didn't know you could multiplty arrays.
    #I had Array.new(secret_length) { nil }, but this is cleaner
  end

  def take_turn
    begin
      guess = @guesser.guess(board)
      if @already_guessed.include?(guess)
        puts "You've already guessed this letter!"
        raise ArgumentError
      else
        @already_guessed << guess
      end
    rescue
      retry
    end

    indices = @referee.check_guess(guess)
    update_board(guess, indices)

    @guesses_left -= 1 if indices.empty?

    @guesser.handle_response(guess, indices)
  end


  def update_board(guess, indices)
    indices.each do |i|
      board[i] = guess
    end
  end

  def game_won?
    board.all?
  end

  def render_game(board)
    print "\nSecret Word >> "
    puts board.map { |ch| ch.nil? ? "_" : ch  }.join
  end
end


class HumanPlayer
  def register_secret_length(length)
    puts "The secret word's length is #{length} letters long"
  end

  def handle_response(guess, indices)
    puts "Guess: #{guess}"
    puts "Found: #{indices.count}"
  end

  def guess(board)
    puts "Please enter a letter:"
    print " >> "
    begin
      guess = $stdin.getc
      raise unless /[a-z]/.match(guess)
    rescue
      retry
    end

    guess
  end

  def pick_secret_word
    puts "Think of a word..."; sleep 1
    puts "What is the length of that word?"
    print " >> "
    begin
      length = gets.to_i
      raise if length == 0
    rescue
      retry
    end

    length
  end

  def check_guess(guess)
    puts "\nPlayer guessed the letter #{guess}"
    puts "\nIn what positions, if any, does it appear?"
    puts "Use digits 1, 2, 3, 4, etc. for positions, separated by commas."
    puts "Use 0 if it is not in your secret word."
    puts "\nExample -- Secret Word: apple"
    puts "                 Guess: p"
    puts "             Positions: 2, 3"
    print " >> "

    begin
      response = gets.chomp
      return [] if /0/.match(response)
      response.split(", ").map { |pos| Integer(pos) - 1 }
    rescue
      retry
    end
  end

  def require_secret
    puts "What word were you thinking of?"

    gets.chomp
  end
end

class ComputerPlayer
  attr_reader :candidate_words

  def self.input_dictionary(dictionary)
    ComputerPlayer.new(File.readlines(dictionary).map(&:chomp))
  end
  #Factory Method for inputting dictionary

  def initialize(dictionary)
    @dictionary = dictionary
  end

  def pick_secret_word
    @secret_word = @dictionary.sample

    @secret_word.length
  end

  def check_guess(guess)
    matched_indicies = []
    @secret_word.chars.each_with_index do |letter, i|
      matched_indicies << i if letter == guess
    end
    matched_indicies
  end

  def require_secret
    @secret_word
  end

  def register_secret_length(length)
    @candidate_words = @dictionary.select { |word| word.length == length }
  end

  def guess(board)
    # p candidate_words

    frequency_hash = narrow_search(board)

    letter, count = frequency_hash.max_by { |letter, count| count }

    letter
  end

  def narrow_search(board)
    frequencies = Hash.new(0)
    @candidate_words.each do |word|
      used = []
      board.each_with_index do |letter, i|
        if letter.nil?
          frequencies[word[i]] += 1 unless used.include?(word[i])
          used << word[i]
        end
      end
    end
    frequencies
  end

  def handle_response(guess, indices)
    @candidate_words.reject! do |word|
      to_be_deleted = false

      word.chars.each_with_index do |letter, i|
        if letter == guess && !indices.include?(i)
          to_be_deleted = true
          break
        elsif letter != guess && indices.include?(i)
          to_be_deleted = true
          break
        end
      end

      to_be_deleted
    end
  end
end

if __FILE__ == $0
  system('clear')
  print "Should a computer be the guesser? yes/no "
  begin
    choose_guesser = gets.chomp.downcase
    if choose_guesser == "yes"
      guesser = ComputerPlayer.input_dictionary("dictionary.txt")
    elsif choose_guesser == "no"
      guesser = HumanPlayer.new
    else
      raise ArgumentError
    end
  rescue
    retry
  end

  print "Should a computer be the referee? yes/no "
  begin
    choose_ref = gets.chomp.downcase
    if choose_ref == "yes"
      referee = ComputerPlayer.input_dictionary("dictionary.txt")
    elsif choose_ref == "no"
      referee = HumanPlayer.new
    else
      raise ArgumentError
    end
  rescue
    retry
  end

  Hangman.new(guesser: guesser, referee: referee).play
end
