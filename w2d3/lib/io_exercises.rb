# I/O Exercises
#
# * Write a `guessing_game` method. The computer should choose a number between
#   1 and 100. Prompt the user to `guess a number`. Each time through a play loop,
#   get a guess from the user. Print the number guessed and whether it was `too
#   high` or `too low`. Track the number of guesses the player takes. When the
#   player guesses the number, print out what the number was and how many guesses
#   the player needed.
# * Write a program that prompts the user for a file name, reads that file,
#   shuffles the lines, and saves it to the file "{input_name}-shuffled.txt". You
#   could create a random number using the Random class, or you could use the
#   `shuffle` method in array.

def guessing_game
  target = rand(1..100)

  puts "Please, guess a number."

  number_of_guesses = 0
  loop do
    guess = Integer(gets.chomp)
    number_of_guesses += 1

    case guess <=> target
    when 0
      puts "#{guess} is correct! Attempt number: #{number_of_guesses}."
      break
    when 1
      puts "#{guess} is too high!"
    when -1
      puts "#{guess} is too low!"
    end
  end
end

def shuffle_lines(file_name)
  base_name = File.basename(filename, ".*")
  ext = File.extname(file_name)
  File.open("#{base_name}-shuffled#{ext}", "w") do |f|
    File.readlines(file_name).shuffle.each do |line|
        f.puts line.chomp
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length == 1
    shuffle_lines(ARGV.shift)
  else
    puts "ENTER FILENAME TO SHUFFLE"
    filename = gets.chomp
    shuffle_lines(filename)
  end
end
