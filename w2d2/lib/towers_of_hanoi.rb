 # Towers of Hanoi
#
# Write a Towers of Hanoi game:
# http://en.wikipedia.org/wiki/Towers_of_hanoi
#
# In a class `TowersOfHanoi`, keep a `towers` instance variable that is an array
# of three arrays. Each subarray should represent a tower. Each tower should
# store integers representing the size of its discs. Expose this instance
# variable with an `attr_reader`.
#
# You'll want a `#play` method. In a loop, prompt the user using puts. Ask what
# pile to select a disc from. The pile should be the index of a tower in your
# `@towers` array. Use gets
# (http://andreacfm.com/2011/06/11/learning-ruby-gets-and-chomp/) to get an
# answer. Similarly, find out which pile the user wants to move the disc to.
# Next, you'll want to do different things depending on whether or not the move
# is valid. Finally, if they have succeeded in moving all of the discs to
# another pile, they win! The loop should end.
#
# You'll want a `TowersOfHanoi#render` method. Don't spend too much time on
# this, just get it playable.
#
# Think about what other helper methods you might want. Here's a list of all the
# instance methods I had in my TowersOfHanoi class:
# * initialize
# * play
# * render
# * won?
# * valid_move?(from_tower, to_tower)
# * move(from_tower, to_tower)
#
# Make sure that the game works in the console. There are also some specs to
# keep you on the right track:
#
# ```bash
# bundle exec rspec spec/towers_of_hanoi_spec.rb
# ```
#
# Make sure to run bundle install first! The specs assume you've implemented the
# methods named above.

class TowersOfHanoi
  attr_reader :towers

  def initialize
    @total_rings = 3
    @towers = [[3, 2, 1], [], []]
  end

  def play
    display

    until youve_won_the_game?
      from_tower_text
      from_tower = gets.chomp
      break if back_door?(from_tower)
      from_tower = from_tower.to_i - 1

      to_tower_text
      to_tower = gets.chomp
      break if back_door?(to_tower)
      to_tower = to_tower.to_i - 1


      if valid_move?(from_tower, to_tower)
        move(from_tower, to_tower)
        display
      else
        display
        invalid_move_text
      end
    end

    puts "Congratulations! You've won!"
    start_a_new_game_prompt
  end

  # ------------------------------------------------------------------------------
  # MECHANICS

  def display
    system('clear')
    puts render
  end

  def render
    puts %Q(:Tower 1: \n#{@towers[0].reverse.join("\n")} \n\n)
    puts %Q(:Tower 2: \n#{@towers[1].reverse.join("\n")} \n\n)
    puts %Q(:Tower 3: \n#{@towers[2].reverse.join("\n")} \n\n)
  end

  def valid_move?(from_tower, to_tower)
    return false unless [from_tower, to_tower].all? do |tower_num|
      tower_num.between?(0, 2)
    end

    @towers[from_tower].any? &&
    (@towers[to_tower].empty? ||
    @towers[from_tower].last < @towers[to_tower].last)
  end

  def move(from_tower, to_tower)
    @towers[to_tower] << @towers[from_tower].pop
  end

  def start_a_new_game_prompt
    puts "Would you like to try a tower with a different difficulty? Yes or No?"
    change_difficulty = gets.chomp
    self.start_a_new_game_prompt unless yes_or_no?(change_difficulty)

    case change_difficulty
    when "yes"
      new_difficulty
    when "no"
      play_again
    end
  end

  def back_door?(input)
    ans = input.downcase
    if ans == "solve"
      @towers = [[], [], build_new_tower(@total_rings)]
    else
      false
    end
  end

  def new_difficulty
    height_prompt
    number_of_rings = gets.to_i

    until (3..7).include?(number_of_rings)
      puts "Invalid number of rings. Try again."
      number_of_rings = gets.to_i
    end

    self.restart(number_of_rings)
  end

  def play_again
    puts "Would you like to play again? Yes or No?"
    new_game = gets.chomp
    self.play_again unless yes_or_no?(new_game)

    self.restart if new_game == "yes"
  end

  def yes_or_no?(input)
    ans = input.downcase
    ans == "yes" || ans == "no"
  end

  def build_new_tower(num_of_rings)
    Array.new(num_of_rings) { |i| num_of_rings - i }
  end

  def restart(num_of_rings = 3)
    @total_rings = num_of_rings
    @towers = [build_new_tower(num_of_rings), [], []]

    self.play
  end

  def youve_won_the_game?
    @towers[1].count == @total_rings || @towers[2].count == @total_rings
  end

# ------------------------------------------------------------------------------
# TEXT HELPERS

  def from_tower_text
    puts "From what tower do you want to take a ring?"
    puts "Choose: 1, 2, or 3."
    puts ""
  end

  def to_tower_text
    puts "To what tower should the ring be moved?"
    puts "Choose: 1, 2, or 3."
    puts ""
  end

  def invalid_move_text
    puts "That move is invalid."
    puts "Try again."
    puts ""
  end

  def height_prompt
    puts "How many rings should be placed on the Tower of Hanoi?"
    puts "Please, select a number of rings between 3 and 7."
    puts ""
  end
end

# ------------------------------------------------------------------------------
if __FILE__ == $0
  new_game = TowersOfHanoi.new
  new_game.play
end
