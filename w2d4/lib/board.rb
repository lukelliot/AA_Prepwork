class Board
  attr_reader :grid, :size

  def self.new_board(n = 3)
    Array.new(n) { Array.new(n) }
  end

  def initialize(grid = Board.new_board)
    @grid = grid
    @size = grid.length
  end

  def [](x, y)
    grid[x][y]
  end

  def []=(x, y, mark)
    grid[x][y] = mark
  end
  # ^This is neat

  def place_mark(pos, mark)
    if empty?(pos)
      self[*pos] = mark
    else
      raise "Invalid position."
    end
  end

  def empty?(pos)
    self[*pos].nil?
  end

  def winner
    l_diagonal = []
    r_diagonal = []

    grid.each_with_index do |row, i|
      return row[0] if row.win?(size)
      # ^Checks each row for the same symbol^

      cols = []
      (0...size).each do |j|
        cols << grid[j][i]
      end
      return cols.first if cols.win?(size)
      # ^Checks each column using [j, i]]

      l_diagonal << grid[i][i]
      r_diagonal << grid[i][size - 1 - i]
      # ^passes diagonal positions to be checked
      #  at the end of iteration^
    end

    return l_diagonal[0] if l_diagonal.win?(size)
    return r_diagonal[0] if r_diagonal.win?(size)


    nil
  end
  # ^Less iterations? But harder to look at.
  # Also I made this method with the option for different
  # size boards

  def over?
    grid.flatten.none? { |el| el.nil? } || winner
  end
  # ^This was a better solution than what I had
end

class Array
  def win?(n)
    self == Array.new(n) {:X} || self == Array.new(n) {:O}
  end
end
