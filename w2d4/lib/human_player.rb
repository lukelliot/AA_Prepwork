class HumanPlayer
  attr_accessor :mark
  attr_reader :name

  def initialize(name = "p1")
    @name = name
  end

  def display(board)
    row0 = "0 |"
    (0..2).each do |col|
      row0 << (board.empty?([0, col]) ? "   |" : " " + board[0, col].to_s + " |")
    end
    row1 = "1 |"
    (0..2).each do |col|
      row1 << (board.empty?([1, col]) ? "   |" : " " + board[1, col].to_s + " |")
    end
    row2 = "2 |"
    (0..2).each do |col|
      row2 << (board.empty?([2, col]) ? "   |" : " " + board[2, col].to_s + " |")
    end

    puts "    0   1   2  < Y"
    puts "  |-----------|"
    puts row0
    puts "  |-----------|"
    puts row1
    puts "  |-----------|"
    puts row2
    puts "  |-----------|"
    puts "^X"
  end
  # ^This looks wayyy better than what I did

  def move_prompt
    puts ""
    puts %Q(Where would you like to place your mark?)
    puts %Q(Please, input a position in the format: "x, y")
    puts %Q(Then press ENTER.)
    print ">> "
  end

  def get_move
    move_prompt
    position = gets.chomp
    puts %Q(\n)
    unless position.match(/[0-2], [0-2]/)
      puts "Invalid position!\n"
      get_move
    end
    position.split(", ").map(&:to_i)
  end
end
