require_relative 'operator'
require_relative 'division'

class Units
    class Subtraction < Operator
	def initialize(*args)
	    raise UnitsError, "All arguments to #{self.class} must have units" unless args.all? {|a| a.zero? || (a.respond_to?(:units) && a.units) }
	    super
	end

	def +(other)
	    if other.is_a? Units::Addition
		# (a - b) + (c + d) => (c + d) + (a - b)
		other + self
	    elsif other.is_a? Units::Subtraction
		# (a - b) + (c - d) => a - b - (-c) - d
		reduce_and_clone(*operands, -other.operands.first, *other.operands.drop(1))
	    elsif other.is_a? Numeric
		# (a - b) + c => a - b - (-c)
		reduce_and_clone(*operands, -other)
	    else
		super other
	    end
	end

	def -(other)
	    if other.zero?
		if 1 == operands.size
		    operands.first
		else
		    self
		end
	    elsif self == other
		0
	    else
		case other
		    when Numeric	    then reduce_and_clone(*operands, other)
		    when Units::Addition
			# (a - b) - (c + d) => a - b - c - d
			reduce_and_clone(*operands, *other.operands)
		    when Units::Subtraction
			# (a - b) - (c - d) => a - b - c - (-d)
			reduce_and_clone(*operands, other.operands.first, *other.operands.drop(1).map {|op| -op})
		    else self.class.new(*operands, other)
		end
	    end
	end

	def /(other)
	    case other
		when Units::Subtraction then Units::Division.new(self, other)
		else super
	    end
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

	def inspect
	    super ' - '
	end

	# @group Math
	def sqrt
	    @sqrt ||= Units::SquareRoot.new(self)
	end
	# @endgroup

    private
	# The operands of a Subtraction are all stored directly; the negation of
	#  each operand is implicit in the subtraction operator. Consequently,
	#  when reduce() applies the operator to each operand, it doesn't know
	#  to treat them as negative numbers. To compensate for this, negate all
	#  but the first operand before calling reduce(), and then negate them
	#  again afterwards.
	def reduce(*args)
	    result = super(:+, args.first, *args.drop(1).map {|a| -a})
	    if result.length > 1
		result = result.delete_if {|operand| operand.zero?}
		result.empty? ? [0] : [result.first, *result.drop(1).map {|r| -r}]
	    else
		result
	    end
	end
    end

    def self.Subtraction(*args)
	Units::Subtraction.new(*args)
    end
end