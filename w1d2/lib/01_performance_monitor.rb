def measure(repeat = 1, &prc)
  begin_time = Time.now
  repeat.times { prc.call }
  (Time.now - begin_time) / repeat
end
