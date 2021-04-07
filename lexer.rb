require 'yaml'

class Transition
	def initialize(to, on)
		@to = to
		@on = on
	end
	def eat(char)
		if @on.include?(char)
			return @to
		end
		return false
	end
end

class State
	def initialize(id, label = "", error = "")
		@transitions = Array.new
		@id = id
		@is_accepting = label != ""
		@label = label
		@error = error
	end
	def add_transition(t)
		@transitions.push(t)
	end
	def eat(char) 
		transitions.each do |t|
			go_to = t.eat(char)
			if go_to
				return go_to
			end
		end
		return false
	end
	def is_accepting
		return @is_accepting
	end
	def get_class_label
		return @label
	end
	def get_id 
		return @id
	end
end

class DFA
	def initialize(dfa)
		@current_state = -1
		@states = Array.new
		dfa['states'].each do |s|
			alpha_ex_go_to = -1
			do_alpha_ex = false
			s_id = s.keys[0]
			s_data = s.values[0]
			state = State.new(s_id, s_data)
			letters = Array.new
			if not s_data["transitions"].nil?
				s_data["transitions"].each do |t|
					if t[0].is_a?(Array)
						letters += t[0]
						state.add_transition(Transition.new(t[0], t[1]))
					elsif t[0] == 'alpha_ex'
						do_alpha_ex = true
						alpha_ex_go_to = t[1]
					else
						letters += dfa[t[0]]
						state.add_transition(Transition.new(dfa[t[0]], t[1]))
					end
				end
				if do_alpha_ex
					state.add_transition(
						Transition.new(dfa['alpha'] - letters, alpha_ex_go_to)
					)
				end
			end
			@states[state.get_id] = state
		end
	end
end

dfa = DFA.new(
	YAML.load_file('dfa.yml')
)



file = File.open("input.txt")
file_data = file.read
file.close