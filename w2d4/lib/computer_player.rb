class ComputerPlayer
  attr_accessor :mark
  attr_reader :board, :name

  def initialize(name = "p2")
    @name = name
  end

  def display(board)
    @board = board
  end

  def get_move
    moves = []

    (0...board.size).each do |row|
      (0...board.size).each do |col|
        moves << [row, col] if board[row, col].nil?
      end
    end

    moves.each do |move|
      return move if winning_move?(move)
    end

    moves.sample
  end

  def winning_move?(move)
    board[*move] = mark
    if board.winner == mark
      board[*move] = nil
      true
    else
      board[*move] = nil
      false
    end
  end
end
