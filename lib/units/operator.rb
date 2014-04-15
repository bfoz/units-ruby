class Units
    class Operator
	# @!attribute operands
	#   @return [Array]  The operands of the operator
	attr_reader :operands

	def initialize(*args)
	    raise ArgumentError, "Can't initialize #{self.class} without arguments" if args.empty?
	    @operands = Array(args)
	end

	def eql?(other)
	    return zero? if (other == 0)
	    other.is_a?(self.class) && (operands == other.operands)
	end
	alias :== :eql?

	def +@
	    self
	end

	def -@
	    self.class.new *(operands.map {|operand| -operand })
	end

	def +(other)
	    if other.zero?
		if 1 == operands.size
		    operands.first
		else
		    self.dup
		end
	    else
		Units.Addition(self, other)
	    end
	end

	def -(other)
	    if other.zero?
		if 1 == operands.size
		    operands.first
		else
		    self.dup
		end
	    elsif self == other
		0
	    else
		Units.Subtraction(self, other)
	    end
	end

	def *(other)
	    return other if other.zero?
	    operands.map {|operand| operand * other }
		    .reduce {|result, operand| result.send(operator, operand)}
	end

	def /(other)
	    self.class.new *(operands.map {|operand| operand / other })
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

	# This is meant to be called from subclasses, but won't explode if called directly
	def to_s(operator=' ')
	    operands.map {|op| op.is_a?(Units::Operator) ? ('(' + op.to_s + ')') : op}.join(operator)
	end

	# @group Math
	def sqrt
	    self.class.new *(operands.map {|op| op.respond_to?(:sqrt) ? op.sqrt : Math.sqrt(op)})
	end
	# @endgroup

	# @group Numeric
	def abs2
	    self * self
	end

	def zero?
	    operands.all? {|operand| operand.zero? }
	end
	# @endgroup

    private

	def operator
	    case self
		when Units::Addition then :+
		when Units::Division then :/
		when Units::Subtraction then :-
	    end
	end

	# Reduce the length of the operand list by applying the operator to any operand pairs that won't produce more proxy objects
	# @param operator [Symbol]  The operator to apply to the operands
	def reduce(operator, *args)
	    args.reduce([]) do |memo, operand|
		skip = false
		memo.map! do |lhs|
		    next lhs if skip
		    next lhs if [lhs, operand].map {|a| a.respond_to?(:units) && !!a.units }.uniq.size != 1
		    begin
			result = lhs.send(operator, operand)
			if result.is_a?(Numeric)
			    skip = true
			    result
			else
			    lhs
			end
		    rescue
			lhs
		    end
		end
		skip ? memo : memo.push(operand)
	    end
	end
    end
end