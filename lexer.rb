require 'yaml'

class Transition
	def initialize(to, on)
		@to = to
		@on = on
	end
	def read(char)
		if @on == char
			return @to
		else 
			return false
		end
	end
end

class State
	def initialize(id, transitions, label = "")
		@id = id
		@transitions = transitions
		@is_accepting = label != ""
		@label = label 
	end
	def read(char) 
		transitions.each do |t|
			go_to = t.read(char)
			if go_to
				return go_to
			end
		end
		return "ERROR: Illegal character #{char}"
	end
end


# class DFA
# 	@states = Array.new
# 	def initialize(states)
# 		@states.each do |s|
# 	end
# end
thing = YAML.load_file('dfa.yml')

puts thing.inspect

thing['states'].each do |s|
end


file = File.open("input.txt")
file_data = file.read
file.close


# file_data.split('').each do |k|
# 	puts k
# end