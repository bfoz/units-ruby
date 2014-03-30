require_relative 'operator'

class Units
    class Division < Operator
	def +(other)
	    Units::Addition.new(self, other)
	end

	def -(other)
	    Units::Subtraction.new(self, other)
	end

	def *(other)
	    self.class.new(operands.first * other, *(operands.drop(1)))
	end

	def /(other)
	    self.class.new(operands.first, *(operands.drop(1)), other)
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
