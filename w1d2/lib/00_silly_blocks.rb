def reverser(&prc)
  sentence = prc.call

  words = sentence.split

  words.map(&:reverse).join(" ")
end

def adder(add = 1, &prc)
  add + prc.call
end

def repeater(repeat = 1, &prc)
  repeat.times { prc.call }
end
