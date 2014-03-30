require_relative 'operator'

class Units
    class Addition < Operator
	def +(other)
	    return self.dup if other.zero?

	    case other
		when self.class	then self.class.new(*operands, *other.operands)
		else self.class.new(*operands, other)
	    end
	end

	def -(other)
	    return self.dup if other.zero?
	    Units::Subtraction.new(self, other)
	end

	def *(other)
	    return other if other.zero?

	    case other
		when Units::Addition
		    self.class.new *(operands.product(other.operands).map {|a,b| a*b})
		else
		    super
	    end
	end

	def /(other)
	    case other
		when Units::Addition
		    Units::Division.new(self, other)
		else
		    super
	    end
	end

	# Handle conversion methods (to_*) and pass everything else to the wrapped value
	def method_missing(id, *args)
	    if Units.valid_unit?(id) or ((id.to_s =~ /^to_(.+)$/) and Units.valid_unit?($1))
		operands.map {|operand| operand.respond_to?(id) ? operand.send(id) : operand }.reduce(:+)
	    else
		super
	    end
	end

	def to_s
	    super ' + '
	end
    end
end
