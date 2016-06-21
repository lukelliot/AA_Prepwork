class Timer
  attr_accessor :seconds

  def initialize(seconds = 0)
    @seconds = seconds
  end

  def format(number)
    if number < 10
      "0#{number}"
    else
      number.to_s
    end
  end

  def hrs(seconds)
    seconds / 3600
  end

  def mins(seconds)
    (seconds % 3600) / 60
  end

  def secs(seconds)
    seconds % 60
  end

  def time_string
    h = format(hrs(@seconds))
    m = format(mins(@seconds))
    s = format(secs(@seconds))

    "#{h}:#{m}:#{s}"
  end
end
