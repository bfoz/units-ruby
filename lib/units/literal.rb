class Units
    class Literal < Numeric
	attr_reader :units, :value

	def initialize(value, units=nil)
	    @value = value
	    @units = (units.is_a?(Units) ? units : Units.new(units)) if units
	    @units = nil if 0 == @value
	end

	# Pass most everything through to the underlying value
	def method_missing(id, *args)
	    @value.send(id, *args)
	end

	def inspect
	    if @units
		@value.inspect + ' ' + @units.inspect
	    else
		@value.inspect
	    end
	end
	def to_s
	    @value.to_s
	end

	# Convert other into something that can handle being divided by {Literal}
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
		(@units == other.units) and (@value == other.value)
	    else
		(@units == nil) and (@value == other)
	    end
	end
	alias == eql?

	def <=>(other)
	    if other.kind_of? Literal
		if @units
		    @units.eql?(other.units) ? (@value <=> other.value) : nil
		else
		    (@value <=> other.value)
		end
	    elsif other.respond_to? :map
		other.map {|a| self.send(:<=>, a)}
	    else
		@value <=> other
	    end
	end

	# @group Arithmetic
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
	# @endgroup

	private

	# Generic operator handler
	def op(sym, other)
	    if other.kind_of? Literal
		Literal.new(@value.send(sym, other.value), @units ? (@units.send(sym, other.units)) : other.units)
	    elsif other.respond_to? :map
		other.map {|a| self.send(sym, a)}
	    else
		Literal.new(@value.send(sym, other), @units ? (@units.send(sym, other.units)) : other.units)
	    end
	rescue UnitsError
	    raise
	rescue ArgumentError    # Handle units that cancel out
	    @value.send(sym, other)
	rescue NoMethodError
	    Literal.new(@value.send(sym, other), @units)
	end
    end
end
