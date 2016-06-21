require 'io/console'
require_relative 'interface'
require_relative 'board'
require_relative 'ships'

class Human
  attr_accessor :name
  attr_reader :board, :fleet, :ships_destroyed, :ships_unplaced

  def initialize(name = "Gandalf")
    @name = name
    @board = Board.new

    @ships_unplaced = Ship.types.dup
    @fleet = []
    @ships_destroyed = []

    # Ships will move downward through these steps
    # Ships will move from 'uplaced'
    # to 'fleet' when board is populated then
    # ships will move to 'ships_destroyed' when they
    # are destroyed in 'until won?'
  end

  def populate
    until @fleet.count == 5
      case add_remove
      when "Add Ship"
        add_ship
      when "Remove Ship"
        remove_ship
      end
    end

    case confirm_remove
    when "Confirm"
      return
    when "Remove Ship"
      remove_ship
      populate
    end
  end

      def add_remove
        this_or_that("Add Ship", "Remove Ship") do
          if @fleet.count > 0
            puts "\n| #{@fleet.map { |ship| ship.type}.join( " | ")} |"
          else
            puts "\n\n"
          end
          board.render_grid("#{self.name}'s Fleet")
        end
      end
      #This or that choice, to add or remove a ship. Each choice will bring you to
      #the appropriate method to do so

      def confirm_remove
        this_or_that("Confirm", "Remove Ship") do
          puts "\n| #{@fleet.map { |ship| ship.type}.join( " | ")} |"
          board.render_grid("#{self.name}'s Fleet")
          puts "\n" << " " * 14 << "Confirm placement of these ships?"
        end
      end
      #after setting all ships (@fleet.count == 5) it will confirm that these
      #are where you'd like to place your ships, otherwise it will send user back to
      #remove_ship

      def add_ship
        if @ships_unplaced.empty?
          return press_enter { "You have a full fleet! Press ENTER to continue." }
        end

        type = scroll_selection(@ships_unplaced)
        if type
          new_ship = Ship.new(type)
        else
          return
        end

        set_coords(new_ship)
      end
      #logic for adding a ship. 1) check if ships_unplaced is empty?. 2) Creates
      #a new ship. 3) set coordinates (default, then placed ship by user). 4) Push
      #the coordinates of the new ship to @fleet, then sort it.

          def scroll_selection(ships)
            i = 0
            loop do
              display(ships, i)
              case raw_keystroke_data
              when "\r"
                return ships.delete_at(i)
              when "\e[C" #Right Arrow key
                i += 1
                i = i == ships.count ? 0 : i
              when "\e[D" #Left Arrow Key
                i -= 1
                i = i < 0 ? (ships.count-1) : i
              when "\177" #BACKSPACE
                return nil
              when "\u0003"
                "Abort!"
                exit 0
              end
            end
          end
          #scrolls selection of ships in @ships_unplaced
          #using the display below for each iteration of 'i'

              def display(ships, idx)
                title_and_grid

                ship = ships[idx]
                length = Ship.data[ship][:length]
                ship_graphic = "|" << " S |" * length

                puts %Q(\nUse ARROW LEFT and ARROW RIGHT to select a ship.\n\n)
                puts "Press DELETE to go back to the Add/Remove menu."
                puts %Q(Press ENTER to make a selection.\n)
                puts %Q(\n#{idx+1}] #{ship} -- #{length} x 1)
                puts %Q(   _#{"____" * length})
                puts %Q( > #{ship_graphic})
                puts %Q(   -#{"----" * length})
                #Display for ship and length
              end

          def set_coords(ship)
            default_placement(ship)
            rotated = false
            loop do
              begin
                title_and_grid
                place_ship_text

                case raw_keystroke_data
                when "\r" #RETURN key
                  select_ship(ship)
                  return press_enter
                when " " #SPACEBAR
                  rotate(ship, rotated)
                  rotated = rotated ? false : true
                when "\e[A" #Up Arrow
                  shift(ship, 1, y: true)
                when "\e[B" #Down Arrow
                  shift(ship, -1, y: true)
                when "\e[C" #Right Arrow
                  shift(ship, 1, x: true)
                when "\e[D" #Left Arrow
                  shift(ship, -1, x: true)
                when "\177" #BACKSPACE
                  revert(ship)
                  return nil
                when "\u0003"
                  "Abort!"
                  exit 0
                end
              rescue InvalidShip
                "Invalid move"
                retry
              end
            end
          end
          #sets default coordinates, which should be the first space of
          #appropriate length available in a row unoccupied by another
          #ship and not nil. Then loops choice for setting coordinates by
          #ticking up or down a particular x or y axis, skipping over
          #coordinates that occupy another ships space.

              def place_ship_text
                puts "\nUse the ARROW KEYS to move your ship."
                puts "Use SPACEBAR to rotate your ship.\n\n"
                puts "Press DELETE to return to the previous menu."
                puts "Press ENTER to set position."
              end

              def default_placement(ship)
                l = ship.length

                board.grid.each_with_index do |row, y|
                  row.each_cons(l).with_index do |cons, x|
                    break if x + l == 11
                    #break if the set length would go over the edge of the board
                    if cons.all? { |mark| mark == :~ }
                      #checks for an open space
                      l.times do |length|
                        ship.coords << [(x + length), y]
                        #Then set the coordinates of the ship instance
                      end
                      return board.mark_ship(ship.coords, :S)
                      #places ship onto grid
                    end
                  end
                end
              end

              def select_ship(ship)
                board.mark_ship(ship.coords, :F)
                @fleet << ship
                @fleet = @fleet.sort_by { |s| s.length }
                title_and_grid
                article = ship.type[0] == "A" ? "an" : "a"
                puts "\nYou've added #{article} #{ship.type.upcase} to your fleet.\n\n"
              end
              #sets ship by turning it into a small :s to differentiate from
              #future ships placed

              def shift(ship, shift, options)
                board.mark_ship(ship.coords, :~)
                #Takes the ship off of the board to avoid "seeing" itself when avoiding other ships
                new_coords = ship.coords.dup

                loop do
                  new_coords.map! do |xy|
                    #iterates new_coords until it finds a valid space
                    x, y = xy

                    if options[:y]
                      y -= shift
                      unless y.between?(0, 9)
                        board.mark_ship(ship.coords, :S)
                        raise InvalidShip
                      end
                    elsif options[:x]
                      x += shift
                      unless x.between?(0, 9)
                        board.mark_ship(ship.coords, :S)
                        raise InvalidShip
                      end
                    end
                    #shifts the coordinates accordinate to option[axis]

                    [x, y]
                  end


                  next if any_ships_in_the_way?(new_coords)
                  # skips to the next iteration if there's a ship in the way, to try and
                  # find a valid location on the other side, otherwise it will hit a nil location
                  # and trigger #off_the_board?

                  if off_the_board?(new_coords)
                    board.mark_ship(ship.coords, :S)
                    raise InvalidShip
                  elsif valid_ship?(new_coords)
                    break
                  end
                  #Checks for any new coordinates that would be off of the board
                  #or on another ship you've placed, then resets the old coordinates
                  #and returns to #set_coords, then error is raised
                end

                board.mark_ship(new_coords, :S)
                ship.coords = new_coords
                #If iteration gets here, it means 'break' kicked us out of iteration
                #Exchanges old coordinates for new ones since they did not
                #reach the edge of the board or another ship
              end

                  def off_the_board?(coords)
                    coords.any? { |xy| xy.any?(&:nil?) }
                  end

                  def any_ships_in_the_way?(coords)
                    coords.any? do |xy|
                      x, y = xy
                      board.grid[y][x] == :s
                    end
                  end

                  def valid_ship?(coords)
                    coords.all? do |xy|
                      x, y = xy
                      board.grid[y][x] == :~
                    end
                    #checks coordinates to see if they're all marked with :~ Water
                  end

              def rotate(ship, rotated)
                board.mark_ship(ship.coords, :~)
                #remove the coordinates off the grid so the rotation
                #doesn't "see" its own ship's ':S' marks
                new_coords = ship.coords.dup
                center = (ship.length - 1) / 2
                # finds fulcrum index
                fulcrum = new_coords[center]
                fulcrum_x, fulcrum_y = fulcrum
                # separates the coordinates into their x and y

                if rotated
                  (0...center).each do |i|
                    x, y = fulcrum_x + (center - i), fulcrum_y
                    valid_rotation(x, y, ship)
                    new_coords[i] =x, y
                  end
                  (center + 1...ship.length).each do |i|
                    x, y = fulcrum_x - (i - center), fulcrum_y
                    valid_rotation(x, y, ship)
                    new_coords[i] = x, y
                  end
                  #rotates the ship back to it's initial position
                else
                  (0...center).each do |i|
                    x, y = fulcrum_x, fulcrum_y - (center - i)
                    valid_rotation(x, y, ship)
                    new_coords[i] = x, y
                  end
                  #rotates coords for indicies less than center
                  (center + 1...ship.length).each do |i|
                    x, y = fulcrum_x, fulcrum_y + (i - center)
                    valid_rotation(x, y, ship)
                    new_coords[i] = x, y
                  end
                  #rotates coords for indicies greater than center
                end
                # These four iterations rotate the ship around the fulcrum and sets new_coords
                # to the new coordinates based on if 'rotated' == true or false

                if valid_ship?(new_coords)
                  board.mark_ship(new_coords, :S)
                  ship.coords = new_coords
                else
                  board.mark_ship(ship.coords, :S)
                  raise InvalidShip
                end
                #If the new_coords are a valid location for the ship, they will be placed
                #onto the grid, if not then the old coordinates will be replaced, then an error will be raised
              end

                  def valid_rotation(x, y, ship)
                    unless x.between?(0, 9) && y.between?(0, 9)
                      board.mark_ship(ship.coords, :S)
                      raise InvalidShip
                    end
                  end
                  #Checks validity of rotation during iterations to catch
                  #invalid rotations without having to complete iteration

              def revert(ship)
                board.mark_ship(ship.coords, :~)
                ship.coords.clear
                @ships_unplaced << ship.type
                @ships_unplaced.sort_by { |type, data| data[:length] }
              end
              #method for exiting out of Human#add_ship and back to Human#populate
              #replaces 'default coordinates' with :~, clears it's coordinates array
              #and pushes it back to @ships_unplaced

      def remove_ship
        if @fleet.empty?
          return press_enter { "You haven't placed any ships! Press ENTER to continue." }
        end

        choice = preview(@fleet)
        if choice
          @ships_unplaced << choice
          @ships_unplaced = @ships_unplaced.sort_by do |ship_type|
            Ship.data[ship_type][:length]
          end
        end
      end
      #if fleet is empty, it will return there are no ships in hte @fleet
      #preview looks through fleet and highlights the particular ship your cursor is on
      #selection is made by pressing ENTER, which will push selected ship back to @ships_unplaced
      #then sorts @ships_unplaced to be viewed by Human#add_ship later
          def preview(ships)
            i = 0
            loop do
              board.mark_ship(ships[i].coords, :S)

              title_and_grid
              remove_ship_prompt(ships[i])

              case raw_keystroke_data
              when "\r"
                board.mark_ship(ships[i].coords, :~)
                ships[i].coords.clear
                return ships.delete_at(i).type
              when "\e[C" #Right Arrow key
                board.mark_ship(ships[i].coords, :F)
                i += 1
                i = i == ships.count ? 0 : i
              when "\e[D" #Left Arrow Key
                board.mark_ship(ships[i].coords, :F)
                i -= 1
                i = i < 0 ? (ships.count-1) : i
              when "\177" #BACKSPACE
                board.mark_ship(ships[i].coords, :F)
                return nil
              when "\u0003"
                "Abort!"
                exit 0
              end
            end
          end

              def remove_ship_prompt(ship)
                puts "Use LEFT ARROW and RIGHT ARROW to cycle through your fleet.\n\n"
                puts "Remove your #{ship.type.upcase}?\n\n"
                puts "Press DELETE to return to the previous menu."
                puts "Press ENTER to make a selection."
              end

  def attack(opponent)
    begin
      human_turn_ui(opponent)
      coords = get_coords
      return if backdoor(opponent, coords)

      if Board.valid_move?(coords)
        x, y = Board.convert_to_xy(coords)
      else
        press_enter { "Invalid coordinates" }
        raise TargetError
      end

      if opponent.board.hit?(x, y)
        human_turn_ui(opponent)

        damaged_ship = damage_ship(opponent, x, y)
        puts "#{Board.convert_to_ln(x, y)} is a hit!"
        if opponent.ships_destroyed.include?(damaged_ship)
          puts "#{opponent.name}'s #{damaged_ship.upcase} has been destroyed!"
          opponent.ships_destroyed.sort_by { |ship| ship.length }
        end
      else
        human_turn_ui(opponent)
        puts "#{Board.convert_to_ln(x, y)} is a Miss!"
      end
    rescue
      retry
    end
    press_enter { "Press ENTER to switch players."}
  end
  #backdoor 'SOLVE' will solve the puzzle and makes true Battleship#win?, otherwise checks for hit
  #goes through logic to check is ship is destroyed after inputting coordinates.

    def human_turn_ui(opponent)
      TITLE.call
      board.render_grid("#{self.name}'s Fleet")
      opponent_display(opponent)
    end

      def opponent_display(opponent)
        opponent.board.render_display
        if opponent.ships_destroyed.count > 0
          puts "" << "  " << "#{opponent.name}'s Destroyed Ships:"
          puts " | #{opponent.ships_destroyed.join( " | ")} |"
        end
      end

      def get_coords
        puts "Enter coordinates in the format 'XY'."
        puts "Then press ENTER"
        puts "Example: A10\n\n"
        print " >> "
        gets.chomp
      end

      def backdoor(opponent, input)
        if input == "SOLVE"
          opponent.fleet.each do |ship|
            opponent.ships_destroyed << ship.type
          end
          return true
        end
        false
      end

  def title_and_grid
    TITLE.call
    if @fleet.count > 0
      puts "\n| #{@fleet.map { |ship| ship.type}.join( " | ")} |"
    else
      puts "\n\n"
    end
    board.render_grid("#{self.name}'s Fleet")
  end
end
