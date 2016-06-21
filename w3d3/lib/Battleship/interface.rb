TITLE = Proc.new do
  system('clear')
  puts File.read("txt/battleship_title.txt")
end

def raw_keystroke_data
  STDIN.echo = false
  STDIN.raw!

  keystroke = STDIN.getc.chr
  if keystroke == "\e"
    keystroke << STDIN.read_nonblock(3) rescue nil
    keystroke << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return keystroke
end
#^Takes in raw keystrokes to read Arrow Drectional Keys and
# the RETURN key for entry. read_nonblock reads the characters after \e
#if they exist. if not rescue them with nil to go to ensure.  

def tab_carrot(l)
  "^" * l
end

def tab_underscore(l)
  "_" * l
end

def this_or_that(this, that, &blk)
  boolean = true
  u_this = tab_underscore(this.length)
  u_that = tab_underscore(that.length)
  c_this = tab_carrot(this.length)
  c_that = tab_carrot(that.length)
  loop do
    TITLE.call
    blk.call if block_given?
    if boolean
      puts "             ____" << u_this << "_" * 9 << u_that << "_" * 4
      puts "               [ #{this} ]  |    #{that}"
      puts "             ^^^^" << c_this << "^" * 9 << c_that << "^" * 4
    else
      puts "             ____" << u_this << "_" * 9 << u_that << "_" * 4
      puts "                 #{this}    |  [ #{that} ]"
      puts "             ^^^^" << c_this << "^" * 9 << c_that << "^" * 4
    end

    case raw_keystroke_data
    when "\r" # RETURN key
      break
    when "\e[D" # LEFT ARROW
      boolean = true
    when "\e[C" # RIGHT ARROW
      boolean = false
    when "\u0003"
      exit 0
    end
  end

  boolean ? this : that
end

def press_enter(&block)
  if block_given?
    puts block.call
  else
    puts "Press ENTER to continue."
  end
  gets.chomp
  return
end


def damage_ship(opponent, *hit)
  opponent.fleet.each do |ship_data|
    ship_data.coords.each_index do |i|
      if ship_data.coords[i] == hit
        ship_data.coords.delete_at(i)

        if ship_data.coords.empty?
          opponent.ships_destroyed << ship_data.type
          opponent.fleet.delete(ship_data)
        end
        return ship_data.type
      end
    end
  end
end
#Checks if the coords inputted are a hit, then deletes particular coordinate from
#the attacked ship's coordinates array. If coordinates.empty? then that ship is destroyed
#and pushed to Human#ships_destroyed

#There's probably a better way to consolidate which methods with which classes and how they overlap,
#but I figured we'd discuss more best practice stuff like that in class and I thought my time was better spent coding.
