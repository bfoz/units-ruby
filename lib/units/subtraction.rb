require_relative 'operator'

class Units
    class Subtraction < Operator
	def +(other)
	    Units::Addition.new(self, other)
	end

	def -(other)
	    self.class.new(*operands, other)
	end

	# Handle conversion methods (to_*) and pass everything else to the wrapped value
	def method_missing(id, *args)
	    if Units.valid_unit?(id) or ((id.to_s =~ /^to_(.+)$/) and Units.valid_unit?($1))
		operands.map {|operand| operand.respond_to?(id) ? operand.send(id) : operand }.reduce(:-)
	    else
		super
	    end
	end

	def to_s
	    super ' - '
	end
    end
end