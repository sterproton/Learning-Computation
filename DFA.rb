class FARule < Struct.new(:state, :character, :nextState)

  def applyTo(state, character)
    self.state == state && self.character == character
  end

  def follow
    nextState
  end

  def inspect
    "#<FARule #{state.inspect} --#{character}--> #{nextState.inspect}>"
  end

end

class DFARulebook < Struct.new(:rules)

  def nextState(state, character)
    puts "state: #{state} char: #{character} nextState: #{ruleFor(state, character).follow}"
    ruleFor(state, character).follow
  end

  def ruleFor(state, character)
    rules.detect { |rule| rule.applyTo(state, character) }
  end
end


class DFA < Struct.new(:currentState, :acceptStates, :ruleBook)

  def readString(str)
    str.chars.each {|char| readCharacter(char)}
  end

  def readCharacter(char)
    self.currentState = ruleBook.nextState(currentState, char)
  end

  def accepting?
    acceptStates.include?(currentState)
  end
end

rulebook = DFARulebook.new([
  FARule.new(1, 'a', 2), FARule.new(1, 'b', 2),
  FARule.new(2, 'a', 3), FARule.new(2, 'b', 3),
  FARule.new(3, 'a', 4), FARule.new(3, 'b', 5),
  FARule.new(4, 'a', 4), FARule.new(4, 'b', 4),
  FARule.new(5, 'a', 5), FARule.new(5, 'b', 5),
])

# /[ab][ab]bw?/

class DFAGen < Struct.new(:startState, :acceptStates, :ruleBook)
  def toDfa
    DFA.new(startState, acceptStates, ruleBook)
  end

  def accept?(str)
    toDfa.tap {|dfa| dfa.readString(str)}.accepting?
  end
end


resetableDFA = DFAGen.new(1, [5], rulebook)
resetableDFA.accept?('aab')
resetableDFA.accept?('bbb')
resetableDFA.accept?('abb')
resetableDFA.accept?('bab')
# /[ab][ab]bw?/