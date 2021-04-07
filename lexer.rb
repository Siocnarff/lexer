require 'yaml'

class Transition
	def initialize(on, to) 
		@on = on
		@to = to
	end
	def eat(k)
		if @on.include?(k)
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
	def transitions
		return @transitions
	end
	def eat(k)
		@transitions.each do |t|
			go_to = t.eat(k)
			if go_to
				return go_to
			end
		end
		raise @error
	end
	def is_accepting?
		return @is_accepting
	end
	def get_class_label
		return @label
	end
	def get_id 
		return @id
	end
	def get_error 
		return @error
	end
end

class DFA
	def initialize(dfa)
		@buffer = ''
		@current_state = 1
		@states = Array.new
		dfa['states'].each do |s|
			alpha_ex_go_to = -1
			do_alpha_ex = false
			s_id = s.keys[0]
			s_data = s.values[0]
			state = State.new(s_id, s_data["label"], s_data["error"])
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
	def reset
		@buffer = ''
		@current_state = 1
	end
	def eat(k)
		current = @states[@current_state]
		if k.ord == 10
			return false
		end
		if k.ord == 32 and current.is_accepting?
			return [current.get_class_label, @buffer]
		end
		begin
			@current_state = current.eat(k)
		rescue
			if current.is_accepting?
				return [current.get_class_label, @buffer]
			else
				raise current.get_error
			end
		end
		@buffer += k
		return false
	end
	def buffer
		return @buffer
	end
end

dfa = DFA.new(
	YAML.load_file('dfa.yml')
)

file = File.open("input.txt")
file_data = file.read
file.close

count = 1
file_data.split('').each do |k|
	begin
		info = dfa.eat(k)
		if info
			puts "#{count} #{info[0]} #{info[1]}"
			dfa.reset
			count += 1
		end
	rescue Exception => e
		puts "\n======================================="
		puts "    ERROR at text: #{dfa.buffer}"
		puts "    #{e}"
		puts "    #{k} is illegal here."
		puts "=======================================\n"
		break
	end
end