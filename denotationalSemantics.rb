require 'treetop'

class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "«#{self}»"
  end
  
  def toRuby
    "-> e {#{value.inspect}}"
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
  def toRuby
    "-> e {#{value.inspect}}"
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "(+ #{left} #{right})"
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end

  def inspect
    "«#{self}»"
  end
  def toRuby
    "-> e { (#{left.toRuby}).call(e) + (#{right.toRuby}).call(e) }"
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
  def toRuby
    "-> e { (#{left.toRuby}).call(e) - (#{right.toRuby}).call(e) }"
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
  def toRuby
    "-> e { (#{left.toRuby}).call(e) * (#{right.toRuby}).call(e) }"
  end
end

class Div < Struct.new(:left, :right)
  def to_s
    "(/ #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end
  def toRuby
    "-> e { (#{left.toRuby}).call(e) / (#{right.toRuby}).call(e) }"
  end
end

class Not < Struct.new(:expression)
  def to_s
    "(not #{expression})"
  end

  def inspect
    "«#{self}»"
  end

  def toRuby
    "-> e { !(#{expression.toRuby}).call(e) }"
  end
end

class And < Struct.new(:left, :right)
  def to_s
    "(and #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def toRuby
    "-> e { (#{left.toRuby}).call(e) && (#{right.toRuby}).call(e) }"
  end
end


class Or < Struct.new(:left, :right)
  def to_s
    "(or #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def toRuby
    "-> e { (#{left.toRuby}).call(e) || (#{right.toRuby}).call(e) }"
  end
end

class Equal < Struct.new(:left, :right)
  def to_s
    "(= #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def toRuby
    "-> e { (#{left.toRuby}).call(e) == (#{right.toRuby}).call(e) }"
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "(< #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def toRuby
    "-> e { (#{left.toRuby}).call(e) < (#{right.toRuby}).call(e) }"
  end
end

class MoreThan < Struct.new(:left, :right)
  def to_s
    "(> #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end
  
  def toRuby
    "-> e { (#{left.toRuby}).call(e) >= (#{right.toRuby}).call(e) }"
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "«#{self}»"
  end

  def toRuby
    "-> e { e[#{name.inspect}] }"
  end
end


class DoNothing
  def to_s
    'do-nothing'
  end

  def inspect
    "«#{self}»"
  end
  def toRuby
    "-> e { e }"
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "(set! #{name} #{expression})"
  end

  def inspect
    "«#{self}»"
  end
  def toRuby
    "-> e { e.merge({ #{name.inspect} => (#{expression.toRuby}).call(e) })}"
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
  def toRuby
    "-> e {
      if (#{condition.toRuby}).call(e)
        (#{consequence.toRuby}).call(e)
      else
        (#{alternative.toRuby}).call(e)
      end
    }"
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
  def toRuby
    "-> e {
      while (#{condition.toRuby}).call(e)
        e = (#{body.toRuby}).call(e)
      end
      e
    }"
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

  def toRuby
    "-> e {
      (#{second.toRuby}).call((#{first.toRuby}).call(e))
    }"
  end

end

SimplePaeser = Treetop.load('simple')
parsedTree = SimplePaeser.new.parse('while (x < 50) { x = x * 3 }')
eval(LessThan.new(Number.new(5),Number.new(10)).toRuby).call({})
statement = parsedTree.to_ast
eval(statement.toRuby).call({x:5})