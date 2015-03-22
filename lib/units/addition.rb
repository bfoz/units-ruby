require_relative 'operator'
require_relative 'square_root'

class Units
    class Addition < Operator
	def initialize(*args)
	    raise UnitsError, "All arguments to #{self.class} must have units" unless args.all? {|a| a.zero? || (a.respond_to?(:units) && a.units) }
	    super
	end

	def +(other)
	    if other.zero?
		if 1 == operands.size
		    operands.first
		else
		    self
		end
	    elsif other.is_a? self.class
		reduce_and_clone(*operands, *other.operands)
	    elsif other.is_a? Numeric
		reduce_and_clone(*operands, other)
	    else
		self.class.new(*operands, other)
	    end
	end

	def -(other)
	    if other.is_a?(Numeric)
		reduce_and_clone(*operands, -other)
	    elsif other.is_a?(self.class)
		reduce_and_clone(*operands, *other.operands.map {|op| -op})
	    elsif other.is_a?(Units::Subtraction)
		reduce_and_clone(*operands, -other.operands.first, *other.operands.drop(1))
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

	def inspect
	    super ' + '
	end

	# @group Math
	def sqrt
	    @sqrt ||= Units::SquareRoot.new(self)
	end
	# @endgroup

    private
	def reduce(*args)
	    result = super(:+, *args)
	    if result.length > 1
		result = result.delete_if {|operand| operand.zero?}
		result.empty? ? [0] : result
	    else
		result
	    end
	end
    end

    def self.Addition(*args)
	Units::Addition.new(*args)
    end
end
