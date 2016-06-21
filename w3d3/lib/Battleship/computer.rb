require_relative 'board'
require_relative 'ships'

class Computer
  attr_reader :board, :ships_destroyed, :fleet, :ships_unplaced, :name, :remaining_targets, :followup_attacks, :priority_attacks

  ROBOT_NAMES = [
    'HAL 9000',
    'Futura',
    'Johnny 5',
    'Bender',
    'R2-D2',
    'Gort',
    'Box',
    'WALL-E',
    'Roy Batty',
    'Megatron',
    'T-800',
    'American Predator Drones'
  ]

  def initialize
    @board = Board.new
    @name = ROBOT_NAMES.sample
    @ships_unplaced = Ship.types.dup
    @fleet = []
    @ships_destroyed = []

    @remaining_targets = {
      0 => [*0..9],
      1 => [*0..9],
      2 => [*0..9],
      3 => [*0..9],
      4 => [*0..9],
      5 => [*0..9],
      6 => [*0..9],
      7 => [*0..9],
      8 => [*0..9],
      9 => [*0..9]
    }
    @followup_attacks = []
    @priority_attacks = []
    #used for strategy. @remaining_targets is a hash, X axis => Y axis
    #followup_attacks saves nearest available coordinates surrounding a hit
    #priority attacks saves coords once a line pattern has been established
  end

  def populate
    until fleet.count == 5
      ship_type = ships_unplaced[-1]
      length = Ship.data[ship_type][:length]
      #grabs ship length from Ship.data

      new_coords = random_coordinates(length)
      if valid_ship?(new_coords)
        board.mark_ship(new_coords, :F)
        #checks the validity of created random coordinates
        @ships_unplaced.delete_at(-1)
        #deleted ship will shift new ship to index '-1'
        new_ship = Ship.new(ship_type)
        new_ship.coords = new_coords
        @fleet << new_ship
        #create new ship, sets coordinates, and pushes it to @fleet
      end
    end
  end

      def valid_ship?(coords)
        coords.all? do |xy|
          x, y = xy
          board.grid[y][x] == :~
        end
      end
      #returns true if all spaces that ship is on are :~ (Water)

      def random_series(length)
        start_of_length = rand(0..10-length)
        #sets random start position for the length of ship
        #uses range (0..10-length) to ensure that no coordinates will
        #find a nil position
        axis_coordinates = []
        length.times { |i| axis_coordinates << start_of_length + i }
        axis_coordinates
        #pushes series of digits to axis_coordinates
      end

      def random_coordinates(length)
        vert_or_horz = rand(0..1)
        #randomizes horizontal or vertical orientation
        axis2 = rand(0..9)
        #sets random axis to remain static
        random_series(length).map do |axis1|
          if vert_or_horz == 0
            [axis2, axis1]
            #vertical coordinates
          elsif vert_or_horz == 1
            [axis1, axis2]
            #horizontal coordinates
          end
        end
      end

  def attack(opponent)
    if followup_attacks.count > 0 || priority_attacks.count > 0
      engage(opponent)
    else
      hunt(opponent)
    end
    press_enter { "Press ENTER to switch players" }
  end

      def hunt(opponent)
        x = remaining_targets.keys.sample
        y = remaining_targets[x].sample
        @remaining_targets[x].delete(y)
        @remaining_targets.delete(x) if @remaining_targets[x].empty?

        if opponent.board.hit?(x, y)
        #if the coordinate is a hit, it will replace the :F with a :X on the opponent's board
          opponent_turn_ui(opponent, x, y)

          damaged_ship = damage_ship(opponent, x, y)
          #damage_ship will remove the approprate coordinate from ship.coords
          #if the ship was destroyed it will remove it from @fleet and move it to
          #ships_destroyed
          if opponent.ships_destroyed.include?(damaged_ship)
            clear_ship(opponent, damaged_ship)
            #clear the followup_attacks if it gets destroyed
          else
            puts "#{self.name} has hit your #{damaged_ship.upcase}!"
          end
          find_followup_attacks(x, y)
          #set instance variable so that on the next turn the computer will continue to attack
          #"around" the previous hit to locate the rest of the ship
        else
          opponent_turn_ui(opponent, x, y)
          miss_text(x, y)
        end
      end

          def opponent_turn_ui(human, x, y)
            TITLE.call
            human.board.render_grid("#{human.name}'s Fleet")
            board.render_display
            puts "#{self.name}'s turn to attack."
            puts "#{self.name} attacks #{Board.convert_to_ln(x, y)}!"; sleep 1
          end

          def find_followup_attacks(x, y)
            if @remaining_targets.key?(x+1) && @remaining_targets[x+1].include?(y)
              @remaining_targets[x+1].delete(y)
              @remaining_targets.delete(x+1) if @remaining_targets[x+1].empty?
              @followup_attacks << [x+1, y, "x"]
            end
              #moves the coords to the right of hunt coordinates to @followup_attacks
            if @remaining_targets.key?(x-1) && @remaining_targets[x-1].include?(y)
              @remaining_targets[x-1].delete(y)
              @remaining_targets.delete(x-1) if @remaining_targets[x-1].empty?
              @followup_attacks << [x-1, y, "-x"]
            end
              #moves the coords to the left of hunt coordinates to @followup_attacks
            if @remaining_targets.key?(x) && @remaining_targets[x].include?(y+1)
              @remaining_targets[x].delete(y+1)
              @remaining_targets.delete(x) if @remaining_targets[x].empty?
              @followup_attacks << [x, y+1, "y"]
            end
              #moves the coords below hunt coordinates to @followup_attacks
            if @remaining_targets.key?(x) && @remaining_targets[x].include?(y-1)
              @remaining_targets[x].delete(y-1)
              @remaining_targets.delete(x) if @remaining_targets[x].empty?
              @followup_attacks << [x, y-1, "-y"]
              #moves the coords above hunt coordinates to @followup_attacks
            end
          end

          def clear_ship(opponent, damaged_ship)
            @followup_attacks.clear
            puts "#{self.name} has sunk your #{damaged_ship.upcase}!"
            opponent.ships_destroyed.sort_by { |ship| ship.length }
          end
          #clears @hit and @followup_attacks so that the next
          #Computer#attack(opponent) will loop to the Hunt mode, and not Engage

          def miss_text(x, y)
            puts "#{Board.convert_to_ln(x, y)} is a miss!"
          end

  def engage(opponent)
    unless @priority_attacks.empty?
      priority = @priority_attacks.sample
      fua_x, fua_y, shift = @priority_attacks.delete(priority)
    else
      follow_up = @followup_attacks.sample
      fua_x, fua_y, shift = @followup_attacks.delete(follow_up)
    end
    #extracts coordinates from followup_attacks created in Hunt mode or from priority_attacks
    if opponent.board.hit?(fua_x, fua_y)
      #if it's a hit, delete the proper coordinate, and place the approprate mark on the grid
      opponent_turn_ui(opponent, fua_x, fua_y)

      prioritize_inline_coords(shift)
      #once a row of "hits" has been established, it will continue to attack in that
      #line, in both directions
      damaged_ship = damage_ship(opponent, fua_x, fua_y)
      #marks the damage onto the ship on board.grid, then checks if that particular ship
      #has been destroyed
      if opponent.ships_destroyed.include?(damaged_ship)
        clear_ship(opponent, damaged_ship)
        #if destroyed, clear the coordinates for hit and followup_attacks, it
        #should go back to Hunt mode next turn
      else
        case shift
        when "x"
          fua_x += 1
        when "-x"
          fua_x -= 1
        when "y"
          fua_y += 1
        when "-y"
          fua_y -= 1
        end
        if @remaining_targets.key?(fua_x) && @remaining_targets[fua_x].include?(fua_y)
          @remaining_targets[fua_x].delete(fua_y)
          @remaining_targets.delete(fua_x) if @remaining_targets[fua_x].empty?
          @priority_attacks << [fua_x, fua_y, shift]
        end
        # If the ship is not destroyed, instead shift up the coordinates again
        #for next turn for priority_attacks
        puts "#{self.name} has hit your #{damaged_ship.upcase}!"
      end
    else
      opponent_turn_ui(opponent, fua_x, fua_y)
      prioritize_alt_coords(shift)
      miss_text(fua_x, fua_y)
    end
  end

      def prioritize_inline_coords(shift)
        alt_shift = shift.length == 1 ? "-#{shift}" : shift[1]
        @followup_attacks.each do |coords|
          if coords.last == alt_shift
            @priority_attacks << @followup_attacks.delete(coords)
          end
        end
      end
      #prioritizes coordinates with opposite symbol of the hit coordinates

      def prioritize_alt_coords(shift)
        if /x/.match(shift)
          @followup_attacks.each do |coords|
            if /y/.match(coords.last)
              @priority_attacks << @followup_attacks.delete(coords)
            end
          end
        else
          @followup_attacks.each do |coords|
            if /x/.match(coords.last)
              @priority_attacks << @followup_attacks.delete(coords)
            end
          end
        end
      end
      #prioritizes coordinates with opposite axis of missed coordinates
end
