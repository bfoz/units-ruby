require_relative 'operator'
require_relative 'addition'
require_relative 'subtraction'

class Units
    class SquareRoot < Operator
	# @param arg [Operator]	A single {Operator} to use as the operand
	def initialize(arg)
	    raise ArgumentError, "SquareRoot is only for Operators, not #{arg}" unless arg.is_a?(Units::Operator)
	    super arg
	end

	def <=>(other)
	    case other
		when Units::Numeric
		    convert_to(other.units**2) <=> other
		else
		    raise ArgumentError, "Can't spaceship with '#{other}'"
	    end
	end

	def -@
	    Units.Subtraction(0, self)
	end

	def *(other)
	    return other if other.zero?
	    self.class.new(operands.first * other.abs2)
	end

	def /(other)
	    self.class.new(operands.first / other.abs2)
	end

	# Handle conversion methods (to_*) and pass everything else to the wrapped value
	def method_missing(id, *args)
	    if Units.valid_unit?(id) or ((id.to_s =~ /^to_(.+)$/) and Units.valid_unit?($1))
		Math.sqrt(operands.first.send(id))
	    else
		super
	    end
	end

	# Convert all of the operands to the given units and perform the proxied operation
	# @param units [Unit]	the desired {Unit}s to convert to
	# @return [Number]  the result of the proxied operation
	def convert_to(units)
	    Math::sqrt(operands.first.convert_to(units))
	end
	alias to convert_to

	def to_s
	    'sqrt(' + operands.first.to_s + ')'
	end

	def inspect
	    'sqrt(' + operands.first.inspect + ')'
	end

	# @group Numeric
	def abs2
	    operands.first
	end

	# @return [Bool]    Returns true if the operand is zero, otherwise nil. There's no way to know for sure that the result won't be zero, if the operand isn't zero.
	def zero?
	    operands.first.zero? ? true : nil
	end
	# @endgroup
    end

    def self.SquareRoot(arg)
	Units::SquareRoot.new(arg)
    end
end