class Units
    class Operator
	# @!attribute operands
	#   @return [Array]  The operands of the operator
	attr_reader :operands

	def initialize(*args)
	    @operands = Array(args)
	end

	def eql?(other)
	    other.is_a?(self.class) && (operands == other.operands)
	end
	alias :== :eql?

	def *(other)
	    self.class.new *(operands.map {|operand| operand.send(:*, other) })
	end

	def /(other)
	    self.class.new *(operands.map {|operand| operand.send(:/, other) })
	end

	# Convert other into something that can handle being divided by {Numeric}
	def coerce(other)
	    case other
		when Fixnum, Float then [Units::Numeric.new(other), self]
		else
		    [other, self]
	    end
	end

	def respond_to_missing?(name, include_private = false)
	    if Units.valid_unit?(name) or ((name.to_s =~ /^to_(.+)$/) and Units.valid_unit?($1))
		true
	    else
		super
	    end
	end
    end
end