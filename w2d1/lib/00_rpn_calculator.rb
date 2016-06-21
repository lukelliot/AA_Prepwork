class RPNCalculator
  def initialize
    @stack = []
  end

  OPERATORS = %W(+ - / *)

  def push(num)
    @stack << num
  end

  def plus
    operation(:+)
  end

  def minus
    operation(:-)
  end

  def times
    operation(:*)
  end

  def divide
    operation(:/)
  end

  def tokens(tokens)
    tokens.split.map do |tok|
      operator?(tok) ? tok.to_sym : tok.to_i
    end
  end

  def evaluate(tokens)
    tokens(tokens).each do |tok|
      if tok.is_a?(Integer)
        push(tok)
      elsif tok.is_a?(Symbol)
        operation(tok)
      end
    end

    value
  end

  def value
    @stack.last
  end

  def self.prompt
    puts "Please, input a number or an operator into the calculator."
    puts "Press ENTER to calculate."
    print ">"
  end

  def self.run_user_interface
    calculator = RPNCalculator.new
    tokens = ""

    loop do
      prompt
      input = gets.chomp
      break if input.empty?
      tokens << " #{input}"
    end

    puts calculator.evaluate(tokens)
  end

  def self.evaluate_file(filename)
    filename.each do |line|
      tokens = line.chomp
      calculator = RPNCalculator.new
      puts calculator.evaluate(tokens)
    end
  end
  #^ Factory method to create calc from text file
  private


  def operator?(op)
    OPERATORS.include?(op)
  end

  def operation(op)
    raise "calculator is empty" unless @stack.count >= 2

    right_operand = @stack.pop
    left_operand = @stack.pop

    case op
    when :+
      @stack << left_operand + right_operand
    when :-
      @stack << left_operand - right_operand
    when :*
      @stack << left_operand * right_operand
    when :/
      @stack << left_operand.fdiv(right_operand)
    else
      @stack << left_operand << right_operand
      raise ArgumentError.new("No function for #{op}")
    end

    self
  end
end

if __FILE__ == $0
  if ARGV.empty?
    RPNCalculator.run_user_interface
  else
    File.open(ARGV.first) do |file|
      puts RPNCalculator.evaluate_file(file)
    end
  end
end
