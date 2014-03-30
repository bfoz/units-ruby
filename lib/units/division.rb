require_relative 'operator'
require_relative 'addition'

class Units
    class Division < Operator
	def -@
	    self.class.new -operands.first, *(operands.drop(1))
	end

	def +(other)
	    Units::Addition.new(self, other)
	end

	def -(other)
	    Units::Subtraction.new(self, other)
	end

	def *(other)
	    case other
		when Units::Addition	then other * self
		when Units::Subtraction	then other * self
		when Units::Division then self.class.new *(operands.zip(other.operands).map {|a,b| (a && b) ? (a * b) : (a || b)})
		else self.class.new(operands.first * other, *(operands.drop(1)))
	    end
	end

	def /(other)
	    case other
		when Units::Division then self.class.new(self, other)
		else self.class.new(operands.first, *(operands.drop(1)), other)
	    end
	end

	# Handle conversion methods (to_*) and pass everything else to the wrapped value
	def method_missing(id, *args)
	    if Units.valid_unit?(id) or ((id.to_s =~ /^to_(.+)$/) and Units.valid_unit?($1))
		operands.map {|operand| operand.respond_to?(id) ? operand.send(id) : operand }.reduce(:/)
	    else
		super
	    end
	end

	def to_s
	    super ' / '
	end
    end
end
