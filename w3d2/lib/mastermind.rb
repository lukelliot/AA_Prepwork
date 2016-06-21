=begin

To AppAcademy,

The top part of this file is the Mastermind game as it was required by the RSPEC
Below that, uncommented, is a some experimenting with the basic mastmind game with added
stuff like a story, different levels, and a timer.
I hope you take a look at both!

=end

# class Code
#   attr_reader :pegs
#
#   PEGS = {
#     "r" => :Red,
#     "g" => :Green,
#     "b" => :Blue,
#     "y" => :Yellow,
#     "o" => :Orange,
#     "p" => :Purple
#   }
#
#   def initialize(pegs)
#     @pegs = pegs
#   end
#
#   def self.parse(pegs_str)
#     new_pegs_sequence = pegs_str.downcase.split(//).map do |letter|
#       raise "invalid peg colors" unless PEGS.has_key?(letter)
#       PEGS[letter]
#     end
#
#     Code.new(new_pegs_sequence)
#   end
#
#   def self.random
#     new_pegs_sequence = []
#     4.times { new_pegs_sequence << PEGS.values.sample }
#
#     Code.new(new_pegs_sequence)
#   end
#
#   def [](i)
#     pegs[i]
#   end
#
#   def ==(compared_code)
#     return false unless compared_code.is_a?(Code)
#
#     self.pegs == compared_code.pegs
#   end
#
#   def exact_matches(master_code)
#     (0..3).select { |i| self[i] == master_code[i] }.count
#   end
#
#   def find_imperfect_indices(master_code)
#     (0..3).reject { |i| self[i] == master_code[i] }
#   end
#
#   def find_near_matches(master_code, imperfect_indices)
#     checked = []
#     near_matches = 0
#
#     imperfect_indices.each do |i|
#       imperfect_indices.each do |j|
#         unchecked = checked.none? { |peg| self[i] == peg }
#         is_match = self[i] == master_code[j]
#
#         if i != j && unchecked && is_match
#           checked << self[i]
#           near_matches += 1
#           break
#         end
#       end
#     end
#
#     near_matches
#   end
#
#   def near_matches(master_code)
#     imperfect_indices = find_imperfect_indices(master_code)
#
#     find_near_matches(master_code, imperfect_indices)
#   end
# end
#
# #------------------------------------------------------------------
#
# class Mastermind
#   attr_reader :secret_code
#
#   def initialize(secret_code = Code.random)
#     @secret_code = secret_code
#     @max_turns = 10
#   end
#
#   def get_guess
#     begin
#       puts ""
#       puts "Guess a four letter code."
#       print ">> "
#       Code.parse(gets.chomp)
#     rescue
#       puts "Error: unable to parse code!"
#       retry
#     end
#   end
#
#   def play
#     system('clear')
#     @max_turns.times do
#       system('clear')
#       guess = get_guess
#
#       if guess == @secret_code
#         puts "That's correct!"
#         return
#       end
#
#     display_matches(guess)
#     end
#
#     puts "Sorry! You've run out of geusses! Play again?"
#   end
#
#   def change_turns(new_turn_count)
#     @max_turns = new_turn_count
#   end
#
#   def display_matches(guess)
#     exact_matches = guess.exact_matches(secret_code)
#     near_matches = guess.near_matches(secret_code)
#
#     puts "You got #{exact_matches} exact matches!"
#     puts "You got #{near_matches} near matches!"
#   end
# end
#
#
#
# if __FILE__ == $0
#   Mastermind.new.play
# end


# #------------------------------------------------------------------

class Code
  attr_reader :seq, :difficulty

  def initialize(sequence)
    @seq = sequence
    @difficulty = sequence.length
  end
  #initializes code sequence and sets difficult i.e. length

  def self.parse(sequence_str, code)
    unless sequence_str.length == code.difficulty
      raise ArgumentError
    end
    #raise an error if the input sequence is not the same length as the code you're trying break

    new_sequence = sequence_str.split(//).map do |digit|
      raise ArgumentError unless digit.to_i.between?(1, 6)
      digit.to_i
    end
    #raise error if the digits in the sequence are not a digit between 1 and 6

    Code.new(new_sequence)
    #create a new code sequence from the parsed sequence
  end

  def self.random(difficulty)
    Code.new( Array.new(difficulty) { rand(1..6) } )
  end
  #creates a randomly generated code

  def [](i)
    seq[i]
  end
  #shortcut to setting digits in the sequence at a particular index

  def ==(compared_code)
    return false unless compared_code.is_a?(Code)

    self.seq == compared_code.seq
  end
  #shortcut to compare one code t's sequence o another, instead of compared if both are 'Code' classes

  def exact_matches(player_code)
    (0...difficulty).select { |i| self[i] == player_code[i] }.count
  end
  #checks for number of exact matches

  def find_imperfect_indices(player_code)
    (0...difficulty).reject { |i| self[i] == player_code[i] }
  end
  #finds the indicies of all of the imperfect matches to be sent to Code#near_matches

  def near_matches(player_code)
    imperfect_indices = find_imperfect_indices(player_code)

    checked = []
    near_matches = 0

    imperfect_indices.each do |i|
      imperfect_indices.each do |j|
        unchecked = checked.none? { |digit| self[i] == digit }
        is_match = self[i] == player_code[j]

        if i != j && unchecked && is_match
          checked << self[i]
          near_matches += 1
          break
        end
      end
    end

    near_matches
  end
end
#removes perfect matches from array, then iterates over imperfect indicies
#and uses those indicies to check how many remaining matches are "near matches"

#------------------------------------------------------------------

class String
  def typing(speed = 0.01)
    $stdout.sync = true
    self.each_char do |char|
      print char
      sleep speed
    end
    $stdout.sync = false
  end
end
#String method that will flush $stdout so that the text is not printed all at once
#then iterates over each character in the string, letting the console 'sleep' for
#a set amount of time between each character to give it the illusion that it is being
#typed

#------------------------------------------------------------------

class TimeoutException < Exception
end
#exception class for catching the 'timeout' of the @timer_thread

#------------------------------------------------------------------

 #     #
 ##   ##    ##     ####   #####  ######  #####   #    #  #  #    #  #####
 # # # #   #  #   #         #    #       #    #  ##  ##  #  ##   #  #    #
 #  #  #  #    #   ####     #    #####   #    #  # ## #  #  # #  #  #    #
 #     #  ######       #    #    #       #####   #    #  #  #  # #  #    #
 #     #  #    #  #    #    #    #       #   #   #    #  #  #   ##  #    #
 #     #  #    #   ####     #    ######  #    #  #    #  #  #    #  #####


class Mastermind
  attr_reader :guess, :codename

  def initialize
    @one = Code.random(3)
    @two = Code.random(4)
    @three = Code.random(5)
    @len1 = @one.difficulty
    @len2 = @two.difficulty
    @len3 = @three.difficulty
    @turns1 = 12
    @turns2 = 10
    @turns3 = 8
    #initializes three codes, for three levels respectively
    #each level stores its own difficulty to be checked against parsed codes
    #turns stores the number of guesses that user can make before losing the game

    @codename = "007"
    @guess = nil
    #sets default 'codename'
    #and sets an instance variable to hold the user's current guess

    @game_thread = nil
    @timer_thread = nil
    @timer_start = 0
    @timer_duration = rand(290..310)
    @time_remaining = nil
    @timer_checkpoint_hash = Hash.new(0)
    #instance variables for timer thread. var's created to hold the main game thread
    #as well as the timer thread, variables for storing the start time to be compared against
    #midgame, randomizes timer duration (5 minutes +/- 10 seconds), timer checkpoint Hash
    #is used for keeping track of time left and spitting out an appropriate comment by the computer
  end

  def play
    system('clear')
    typing_tabbed("txt/mastermind_title.txt", 0.001, 4)
    case start_mastermind_prompt
    when "n"
      new_game
      play_again_prompt
    when "h"
      how_to_play
      Mastermind.new.play
    when "q"
      abort
    else
      Mastermind.new.play
    end
  end
  #logic for game play routine.

      def start_mastermind_prompt
        sleep 0.5

        line
        tab_title; puts create_title("MAIN MENU") << "\n"
        puts_tabbed("txt/menu.txt", 12)
        tab(12); " >> ".typing
        gets.chomp.downcase
      end
      #prompt for beginning Mastermind, includes main menu

      def new_game
        clear

        dossier
        pre_game
        begin
          timer_thread
          game_thread
          @game_thread.join
          @timer_thread.join
        rescue TimeoutException
          return out_of_time
        end
      end

          def dossier
            puts ""
            tab; ". . .".typing(0.3)
            sleep 0.2
            puts ""
            tab; "*radio static*... ".typing(0.1)
            sleep 1
            print "\n\n"
            tab; puts "What's your codename, Agent?\n"
            tab; print " >> "
            @codename = gets.chomp


            clear
            puts ""
            tab; puts "Agent #{codename}. . ."
            sleep 2
            puts "\n"
            tab; puts "Time is of the essence.\n"
            sleep 1
            tab; puts "Climb into the chopper and we can begin your briefing.\n"

            press_enter { "Press 'ENTER' to get in the helicopter." }
          end
          #gets codename from user, and then prompts them to begin the mission briefing

          def pre_game
            clear
            mission_directive_text
            clear
            codebreaker_protocol_text
            begin_mission_text
          end
          #contains prompts for mission briefing

              def mission_directive_text
                puts "\n"
                tab_title; puts create_title("MISSION BRIEFING") << "\n"
                tab_title; puts "#{Time.now}\n\n"
                puts_tabbed("txt/mission_directive1.txt")
                press_enter
                puts_tabbed("txt/mission_directive2.txt")
                press_enter
                puts_tabbed("txt/mission_directive3.txt")
                press_enter { "Press 'ENTER' to activate your communicator." }
              end
              #text for mission briefing, laid out in three parts to be continued by pressing enter
              #mostly role playing related, not mechanically functional to game

              def codebreaker_protocol_text
                puts "\n"
                tab_title; puts create_title("MISSION BRIEFING") << "\n"
                tab_title; puts "#{Time.now}\n\n"
                sleep 0.5
                tab; ". . .".typing(0.3); sleep 0.2; line
                tab; "--LOADING CODEBREAKER PROTOCOL--".typing(0.1); sleep 0.35; line

                tab_title; create_title("COMMUNICATOR ACTIVATED").typing(0.02); line
                tab; "TESTING MESSAGE DELIVERY SYSTEM".typing; line

                press_enter { "Press 'ENTER' to acknowledge." }
              end
              #continues mission briefing Role play, but switches to 'typing' string method
              #to fit context of the story

              def begin_mission_text
                typing_tabbed("txt/caveats.txt")
                tab; "We recommend avoiding the latter".typing; "...".typing(0.75)
                line; line; sleep 2

                tab; "We'll reach the LZ in just a moment".typing; line
                tab; "Godspeed, Agent #{codename}. We're counting on you...".typing; line

                press_enter { %Q(Press 'ENTER' to begin your mission and start the timer.) }
              end
              #Prompt to begin mission

          def timer_thread
            @timer_thread = Thread.new do
              $stdout.sync = true
              @timer_start = Time.now.to_i
              sleep @timer_duration
              @game_thread.kill
              raise TimeoutException.new
            end
          end
          #method for containing the timer thread. Starts the timer, pushes start time to @timer_start
          #then sleeps the timer for the timer duration instance variable, after completing this sleep
          #it kills the original game thread and throws a timeout exception to send the user to mastermind#out_of_time

          def game_thread
            @game_thread = Thread.new do
              if lvl(@one, @len1, @turns1, "txt/lvl1.txt", 0)
                if lvl(@two, @len2, @turns2, "txt/lvl2.txt", 1)
                  if lvl(@three, @len3, @turns3, "txt/lvl3.txt", 2)
                    end_game
                    Thread.current.kill
                  end
                end
              end
              compromised_text
            end
          end
          #method to contain the original game thread. This is the thread that you
          # will be playing the game on. Contained within are the three levels and codes
          # that must be broken in order to win the game. When teh game is when send the
          # user to end_game and then kill the current game thread

              def lvl(code, length, turns, text_file, lvl)
                clear
                typing_tabbed(text_file)
                line
                tab_title; create_title("CODEBREAKER DISPLAY").typing
                tab(18); "Time Remaining: #{countdown}\n".typing
                empty_code(length, lvl)

                passed = false
                turns.times do |i|
                  @guess = get_guess(code)
                  clear

                  if @guess == code
                    passed = true
                    break
                  end

                  codebreaker_display(0, code, i+1, @guess)
                  line
                  timer_checkpoints
                  be_careful_prompt if i == rand(turns - 4..turns - 2)
                end

                passed
              end
              #for the appropriate number of turns for that particular level, the user is prompted
              #to make a guess at breaking the code, if the guess is corerct, it will break and send the
              #user to the next leve, it not it loops and repeats. If the number of turns remaining
              #is within 3 turns (randomized) then it will return a prompt by computer to be careful while geussing

                  def countdown
                    time_left = self.time_remaining
                    m = (time_left / 60).to_s
                    s = (time_left % 60)
                    s = s >= 10 ? s.to_s : "0#{s}"
                    "0#{m}:#{s}"
                  end
                  #display's time remaining in clock form

                  def empty_code(size, lvl)
                    empty_code = Array.new(size) { '?'.to_sym }.join(" | ")
                    t = (lvl == 0) ? 20 : (lvl == 1) ? 19 : 18.5
                    tab(t)
                    %Q([ #{empty_code} ]).typing
                  end
                  #sets display for code when there is none inputted for current @guess

                      def time_remaining
                        (@timer_start + @timer_duration) - Time.now.to_i
                      end
                      #time remaining on @timer_thread relative to current time

                  def get_guess(code)
                    begin
                      line
                      tab; "ENTER CODE:\n".typing
                      tab; " >> ".typing
                      guess = gets.chomp
                      case guess
                      when "EXIT"
                        abort
                      when "SOLVE"
                        code
                      else
                        Code.parse(guess, code)
                      end
                    rescue
                      tab
                      puts "error: invalid code entry"
                      retry
                    end
                  end
                  #loop for getting guess from user, if guess is equal to 'EXIT' the game will abort
                  #if the guess is equal to 'SOLVE' it will solve the code, else it will attempt to parse code
                  #and send it back to #lvl to be compared

                  def codebreaker_display(lvl, secret_code, guess_num, guess)
                    exact_matches = secret_code.exact_matches(guess)
                    near_matches = secret_code.near_matches(guess)
                    t = self.time_remaining

                    t = (lvl == 0) ? 20 : (lvl == 1) ? 17 : 17
                    line
                    tab_title; create_title("CODEBREAKER DISPLAY").typing
                    tab(21); "Attempt#: #{guess_num}\n".typing
                    tab(19); "Time Remaining: #{countdown}\n".typing
                    tab(t); "[ #{self.guess.seq.join(" | ")} ]\n".typing
                    tab(20); "Perfect Match: #{exact_matches}\n".typing
                    tab(21); "Near Match: #{near_matches}\n".typing
                  end
                  #console display for user's guesses: displaying the guess,
                  # the number of guesses remaining, the time remaining, the number
                  # of perfect and near matches

                  def timer_checkpoints
                    t = self.time_remaining
                    if @timer_checkpoint_hash[30] < 3 && t <= 40
                      @timer_checkpoint_hash[30] += 1
                      tab; "#{@time_remaining} seconds left.\n".typing
                    elsif @timer_checkpoint_hash[120] == 0 && t.between?(60, 140)
                      @timer_checkpoint_hash[120] += 1
                      tab; "Cutting it close, #{codename}".typing
                    elsif @timer_checkpoint_hash[180] == 0 && t.between?(140, 180)
                      @timer_checkpoint_hash[180] += 1
                      tab; "3 minutes. Finish the job.\n".typing
                    elsif @timer_checkpoint_hash[240] == 0 && t.between?(200, 240)
                      @timer_checkpoint_hash[240] += 1
                      tab; "Doing good. 4 minutes left.\n".typing
                    end
                  end
                  #uses @timer_checkpoint_hash to return comments by the computer
                  #based on how much time is remaining on the clock

                  def be_careful_prompt
                    typing_tabbed("txt/be_careful.txt")
                  end


              def end_game
                @timer_thread.kill
                line
                if get_min == 0
                  if get_sec == 1
                    time = "only #{get_sec} second"
                  else
                    time = "#{get_sec} seconds"
                  end
                else
                  if get_min > 1
                    if get_sec == 1
                      time = "#{get_min} minutes and #{get_sec} second"
                    else
                      time = "#{get_min} minutes and #{get_sec} seconds"
                    end
                  else
                    if get_sec == 1
                      time = "#{get_min} minute and #{get_sec} second"
                    else
                      time = "#{get_min} minutes and #{get_sec} seconds"
                    end
                  end
                end
                tab; "With #{time} to spare. Congratulations, #{codename}.\n".typing
                tab; "Mission was a success.\n".typing
              end
              #sets text for winning the game based on time remaining and appropriately
              # setting grammar for that

              def compromised_text
                clear
                tab; "The alarm has been triggered.\n".typing
                tab; "The mission has been compromised\n".typing
                sleep 1
                tab; "They're closing in, Agent!\n".typing
                sleep 1
                tab; "Get out of there, #{codename}!".typing
                ". . .\n".typing(1)
                play_again_prompt
              end
              #if any or all of the levels are not completed in the requisite number
              # of guesses or time, then the compromised text will display
              #this will send the user to the play_again_prompt

                  def play_again_prompt
                    typing_tabbed("txt/play_again.txt")
                    tab; print " >> "
                    play_again = gets.chomp.downcase

                    if play_again == 'y'
                      Mastermind.new.play
                    elsif play_again == "n"
                      tab; "Acknowledged\n".typing
                      tab; "--THIS DEVICE WILL SELF DESTRUCT IN 3 SECONDS--\n".typing
                      tab; (1..3).reverse_each { |n| "#{n}..".typing ; sleep 0.9}
                      line

                      abort
                    else
                      play_again_prompt
                    end
                  end
                  #sends user back to the beginning of Mastermind.new with new codes
                  #otherwise it will abort the console



          def out_of_time
            line
            tab; "You're out of time, Agent.\n".typing
            sleep 1
            tab; "The mission has been compromised".typing
            "....".typing(0.35)
            sleep 1
            line; line
            tab; "Get out of there, #{codename}!\n".typing
            sleep 1
            tab; "Run!\n".typing
          end
          #triggered when @timer_thread sleep timer is up


      def how_to_play
        clear
        line
        tab_title; puts create_title("HOW TO PLAY")
        puts_tabbed("txt/how_to_play.txt")
        press_enter
      end

# Helper Methods

  def get_min
    t = self.time_remaining
    (t / 60)
  end

  def get_sec
    t = self.time_remaining
    (t % 60)
  end

  def press_enter(&block)
    if block_given?
      tab; puts "#{block.call}"
      loop do
        return if gets == "\n"
      end
    else
      tab; puts "Press 'ENTER' to continue."
      loop do
        return if gets == "\n"
      end
    end
  end

  def puts_tabbed(filename, t = 6)
    File.foreach(filename) { |l| tab(t); puts l }
  end

  def typing_tabbed(filename, speed = 0.01, t = 6)
    File.foreach(filename) { |l| tab(t); l.typing(speed) }
  end

  def tab(n = 6)
    print "  " * n
  end

  def tab_title
    print "  " * 16
  end

  def clear
    system('clear')
    puts_tabbed("txt/mastermind_title.txt", 4)
  end

  def line
    puts "\n"
  end

  def create_title(text)
    "[::] #{text} [::]\n"
  end
end


if __FILE__ == $PROGRAM_NAME
  Mastermind.new.play
end
