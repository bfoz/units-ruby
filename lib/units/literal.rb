class Units
    class Literal < Numeric
	attr_reader :literal, :units

	def initialize(literal, units=nil)
	    @literal = literal
	    @units = (units.is_a?(Units) ? units : Units.new(units)) if units
	    @units = nil if 0 == @literal
	end

	# Pass most everything through to the literal
	def method_missing(id, *args)
	    @literal.send(id, *args)
	end

	def inspect
	    if @units
		@literal.inspect + ' ' + @units.inspect
	    else
		@literal.inspect
	    end
	end
	def to_s
	    @literal.to_s
	end

	def coerce(other)
	    case other
		when Fixnum then [Literal.new(other), self]
		when Float  then [Literal.new(other), self]
		else
		    other.class.send(:include, UnitsMixin) unless other.kind_of?(UnitsMixin)
		    [other, self]
	    end
	end

	# Both the values and the units must match for two numbers to be considered equal
	#  ie. 3.meters != 3.inches != 3
	def eql?(other)
	    if other.respond_to?(:units)
		(@units == other.units) and (@literal == other.literal)
	    else
		(@units == nil) and (@literal == other)
	    end
	end
	alias == eql?

	def +(other)
	    op(:+, other)
	end

	def -(other)
	    op(:-, other)
	end

	def *(other)
	    op(:*, other)
	end

	def /(other)
	    op(:/, other)
	end

	private

	# Generic operator handler
	def op(sym, other)
	    if other.kind_of? Literal
		Literal.new(@literal.send(sym, other.literal), @units ? (@units.send(sym, other.units)) : other.units)
	    else
		Literal.new(@literal.send(sym, other), @units ? (@units.send(sym, other.units)) : other.units)
	    end
	rescue UnitsError
	    raise
	rescue ArgumentError    # Handle units that cancel out
	    @literal.send(sym, other)
	rescue NoMethodError
	    Literal.new(@literal.send(sym, other), @units)
	end
    end
end
