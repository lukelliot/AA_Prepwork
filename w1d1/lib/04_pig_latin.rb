def translate(sentence)
  words = sentence.split

  words.map! do |word|
    translate_word(word)
  end
  
  words.join(" ")
end

def translate_word(word)
  cut = 0
  cut += 1 until is_vowel?(word[cut]) && word[cut] != "u"

  first_half, second_half = word[0...cut], word[cut..-1]

  "#{second_half}#{first_half}ay"
end

def is_vowel?(letter)
  %W(a e i o u).include?(letter)
end
