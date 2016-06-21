def echo(echo)
  "#{echo}"
end

def shout(words)
  words.split.map(&:upcase).join(" ")
end

def repeat(word, repeat = 2)
  final = []
  repeat.times { final << word }
  final.join(" ")
end

def start_of_word(word, n)
  word[0...n]
end

def first_word(sentence)
  sentence.split.first
end

def titleize(title)
  little_words = %W(the and over)

  words = title.split

  words = words.each_with_index.map do |word, i|
    if little_words.include?(word) && i > 0
      word
    else
      word.capitalize
    end
  end

  words.join(" ")
end
