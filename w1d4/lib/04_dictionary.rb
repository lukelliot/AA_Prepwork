class Dictionary
  attr_accessor :entries

  def initialize(entries = {})
    @entries = entries
  end

  def add(entry)
    if entry.is_a?(Hash)
      @entries.merge!(entry)
    elsif entry.is_a?(String)
      @entries[entry] = nil
    end
  end

  def keywords
    @entries.keys.sort
  end

  def include?(keyword)
    keywords.include?(keyword)
  end

  def find(str)
    @entries.select do |word, _|
      word[0...str.length] == str
    end
  end

  def printable
    words = @entries.sort.map do |word, definition|
      %Q([#{word}] "#{definition}")
    end

    words.join("\n")
  end
end
