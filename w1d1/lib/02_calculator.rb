def add(*numbers)
  numbers.inject(:+)
end

def subtract(*numbers)
  numbers.inject(:-)
end

def multiply(*numbers)
  numbers.inject(:*)
end

def power(*numbers)
  numbers.inject { |mem, n| mem ** n }
end

def sum(numbers)
  numbers.inject(0) { |mem, n| mem + n }
end

def factorial(number)
  (1..number).inject(1) { |mem, n| mem * n }
end
