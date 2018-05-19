class Machine < Struct.new(:statement, :environment)
    def step
      self.statement, self.environment = statement.reduce(environment)
    end
  
    def run
      while statement.reducible?
        puts "#{statement}\n#{environment}"
        puts ""
        step
      end
      puts "#{statement}\n#{environment}\n"
    end
end

class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "«#{self}»"
  end

  def reducible?
    false
  end
end

class Add < Struct.new(:left,:right)
  def to_s
    "(+ #{left} #{right})"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      Add.new(left.reduce(environment),right)
    elsif right.reducible?
      Add.new(left,right.reduce(environment))
    else
      Number.new(left.value+right.value)
    end
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

  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      Sub.new(left.reduce(environment), right)
    elsif right.reducible? 
      Sub.new(left, right.reduce(environment))
    else
      Number.new(left.value - right.value)
    end
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "(* #{left} #{right})"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      Multiply.new(left.reduce(environment), right)
    elsif right.reducible?
      Multiply.new(left, right.reduce(environment))
    else
      Number.new(left.value * right.value)
    end
  end

  def inspect
    "«#{self}»"
  end
end

class Div < Struct.new(:left, :right)
  def to_s
    "(/ #{left} #{right})"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      Div.new(left.reduce(environment), right)
    elsif right.reducible?
      Div.new(left, right.reduce(environment))
    else
      Number.new(left.value / right.value)
    end
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

  def reducible?
    false
  end
end

class Not < Struct.new(:expression)
  def to_s
    "(not #{expression})"
  end

  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if expression.reducible?
      Not.new(expression.reduce(environment))
    else
      Boolean.new(!expression.value)
    end
  end
end

class And < Struct.new(:left, :right)
  def to_s
    "(and #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      And.new(left.reduce(environment), right)
    elsif right.reducible? 
      And.new(left, right.reduce(environment))
    else
      Boolean.new(left.value && right.value)
    end
  end
end

class Or < Struct.new(:left, :right)
  def to_s
    "(or #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      Or.new(left.reduce(environment), right)
    elsif right.reducible? 
      Or.new(left, right.reduce(environment))
    else
      Boolean.new(left.value || right.value)
    end
  end
end

class Equal < Struct.new(:left, :right)
  def to_s
    "(= #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      Equal.new(left.reduce(environment), right)
    elsif right.reducible?
      Equal.new(left, right.reduce(environment))
    else
      Boolean.new(left.value==right.value)
    end
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "(< #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end
    
  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      LessThan.new(left.reduce(environment), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(environment))
    else
      Boolean.new(left.value < right.value)
    end
  end
end

class MoreThan < Struct.new(:left, :right)
  def to_s
    "(> #{left} #{right})"
  end

  def inspect
    "«#{self}»"
  end
    
  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      MoreThan.new(left.reduce(environment), right)
    elsif right.reducible?
      MoreThan.new(left, right.reduce(environment))
    else
      Boolean.new(left.value > right.value)
    end
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end

  def reduce(environment)
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

  def reducible?
    false
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "(set! #{name} #{expression})"
  end

  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if expression.reducible?
      [Assign.new(name, expression.reduce(environment)), environment]
    else
      [DoNothing.new, environment.merge({ name => expression })]
    end
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

  def reducible?
    true
  end

  def reduce(environment)
    if condition.reducible?
      [If.new(condition.reduce(environment), consequence, alternative), environment]
    elsif condition==Boolean.new(true) 
      [consequence, environment]
    else
      [alternative, environment]
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

  def reducible?
    true
  end

  def reduce(environment)
    case
    when first.reducible?
      reducedFirst, reducedEnvironment = first.reduce(environment)
      [Sequence.new(reducedFirst,second), reducedEnvironment]
    else
      [second, environment]
    end
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

  def reducible?
    true
  end

  def reduce(environment)
    [If.new(condition, Sequence.new(body, self), DoNothing.new), environment]
  end
end

# def Procedure < Struct.new(:name, :x, :body)

#   def initialize
#     @Scope = {}
#   end

#   def to_s
#     "(lambda #{x} #{body})"
#   end

#   def inspect
#     "«#{self}»"
#   end

#   def reducible?
#     true
#   end

#   def reduce(environment)
#     environment.merge({
#       :name => Scope
#     })
#     if body.reducible?
      
#     else
      
#     end
#   end

# end

statement = Sequence.new(
  While.new(
    LessThan.new(Variable.new(:x), Number.new(5)),
    Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
  ),
  DoNothing.new
)

Machine.new(
  statement,
  { x: Number.new(1) }
).run
