class Book
  attr_accessor :title

  LOWERCASE_WORDS = %w(
    the
    a
    an
    and
    in
    of
  )

  def title=(title)
    words = title.downcase.split(" ")

    words = words.each_with_index.map do |word, i|
      if LOWERCASE_WORDS.include?(word) && i > 0
        word
      else
        word.capitalize
      end
    end

    @title = words.join(" ")
  end
end
