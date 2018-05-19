class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    self
  end
end

class Add < Struct.new(:left,:right)
  def to_s
    "(+ #{left} #{right})"
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end

  def inspect
    "«#{self}»"
  end
end

class Sub < Struct.new(:left,:right)
  def to_s
    "(- #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value - right.evaluate(environment).value)
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "(* #{left} #{right})"
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end

  def inspect
    "«#{self}»"
  end
end

class Div < Struct.new(:left, :right)
  def to_s
    "(/ #{left} #{right})"
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value / right.evaluate(environment).value)
  end

  def inspect
    "«#{self}»"
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    self
  end
end

class Not < Struct.new(:expression)
  def to_s
    "(not #{expression})"
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    Boolean.new(!expression.evaluate(environment).value)
  end
end

class And < Struct.new(:left, :right)
  def to_s
    "(and #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value&&right.evaluate(environment).value)
  end
end

class Or < Struct.new(:left, :right)
  def to_s
    "(or #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value||right.evaluate(environment).value)
  end
end

class Equal < Struct.new(:left, :right)
  def to_s
    "(= #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value==right.evaluate(environment).value)
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "(< #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end
    
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value <= right.evaluate(environment).value)
  end
end

class MoreThan < Struct.new(:left, :right)
  def to_s
    "(> #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end
    
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value>=right.evaluate(environment).value)
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    environment[name]
  end
end


class DoNothing
  def to_s
    'do-nothing'
  end

  def inspect
    "«#{self}»"
  end

  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end

  def evaluate(environment)
    environment
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "(set! #{name} #{expression})"
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    environment.merge({
      name=> expression.evaluate(environment)
    })
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "(if #{condition}\n"\
    "  \t#{consequence}\n"\
    "  \t#{alternative})"
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      consequence.evaluate(environment)
    when Boolean.new(false)
      alternative.evaluate(environment)
    end
  end
end

class Sequence < Struct.new(:first, :second)
  def to_s
    "(seq\n"\
    "\t#{first}\n"\
    "\t#{second})"
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end
end

class While < Struct.new(:condition, :body)
  def to_s
    "(while\n"\
    "  \t#{condition}\n"\
    "  \t#{body})"
  end

  def inspect
    "«#{self}»"
  end

  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      evaluate(body.evaluate(environment))
    when Boolean.new(false)
      environment
    end
  end
end

Add.new(
  Number.new(5),
  Number.new(10)
).evaluate({})

statement =
Sequence.new(
Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))
)

statement.evaluate({})
