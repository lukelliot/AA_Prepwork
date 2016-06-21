require_relative 'board'
require_relative 'human_player'
require_relative 'computer_player'

class Game
  attr_accessor :board, :player_one, :player_two, :tally, :current_player

  def initialize(player_one, player_two)
    @board = Board.new
    @player_one, @player_two = player_one, player_two
    player_one.mark = :X
    player_two.mark = :O
    @current_player = player_one
    @tally = Hash.new(0)
  end

  def reset_tally
    @tally = Hash.new(0)
  end

  def switch_symbols
    reset_tally
    if player_one.mark == :X
      player_one.mark, player_two.mark = :O, :X
    else
      player_one.mark, player_two.mark = :X, :O
    end
  end

  def display_tally
    puts %Q(:#{player_one.name}: - #{player_one.mark})
    puts %Q( >> #{@tally[player_one.mark]}\n\n)
    puts %Q(:#{player_two.name}: - #{player_two.mark})
    puts %Q( >> #{@tally[player_two.mark]}\n\n)
    puts %Q(:Ties:)
    puts %Q( >> #{@tally[:Ties]}\n\n\n)
  end

  def switch_players!
    if current_player == player_one
      self.current_player = player_two
    else
      self.current_player = player_one
    end
  end

  def winner_text
    if self.board.winner == player_one.mark
      puts ""
      puts %Q(#{player_one.name} is the winner!)
    elsif self.board.winner == player_two.mark
      puts ""
      puts %Q(#{player_two.name} is the winner!)
    end
  end

  def replay_text
    puts %Q(Would you like to play again?)
    puts %Q(Type "y" or "n" and press ENTER)
    print ">> "
  end

  def title
    puts "---------------"
    puts "| Tic-Tac-Toe |"
    puts "---------------\n\n"
  end

  def end_game
    if board.winner == nil
      puts %Q(Cat's Game!\n)
      tally[:Ties] += 1
    else
      puts winner_text
      tally[board.winner] += 1
    end
  end

  def replay_prompt
    replay_text
    rematch = gets.chomp
    if rematch == "y"
      @board = Board.new
      play
    elsif rematch == "n"
      puts ""
      puts "Final Score: \n"
      display_tally
    end
  end

  def play_turn
    move = current_player.get_move
    board.place_mark(move, current_player.mark)

    unless current_player.is_a?(HumanPlayer) && board.over?
      switch_players!
    end

    current_player.display(board)
  end

  def play
    title
    display_tally
    current_player.display(board)

    until board.over?
      play_turn
    end

    end_game
    replay_prompt
  end
end

if __FILE__ == $0
  lucas = HumanPlayer.new("Lucas")
  pc = ComputerPlayer.new("Spiderman")
  Game.new(lucas, pc).play
end
