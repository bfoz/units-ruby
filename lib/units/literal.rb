class Units
    class Literal < Numeric
	attr_reader :literal, :units
	
	def initialize(literal, units=nil)
	    @literal = literal
	    @units = (units.is_a?(Units) ? units : Units.new(units)) if units
	end
	
	# Pass most everything through to the literal
	def method_missing(id, *args)
	    @literal.send(id, *args)
	end
	
	def inspect
	    @literal.inspect + ' ' + @units.inspect
	end
	def to_s
	    @literal.to_s
	end
	
	# Both the values and the units must match for two numbers to be considered equal
	#  ie. 3.meters != 3.inches != 3
	def ==(other)
	    if other.respond_to?(:units)
		(@units == other.units) and (@literal == other.literal)
	    else
		(@units == nil) and (@literal == other)
	    end
	end
	
	def +(other)
	    Literal.new(@literal + other, @units + other.units)
	rescue NoMethodError
	    Literal.new(@literal + other, @units)
	end

	def -(other)
	    Literal.new(@literal - other, @units - other.units)
	rescue NoMethodError
	    Literal.new(@literal - other, @units)
	end

	def *(other)
	    Literal.new(@literal * other, @units * other.units)
	rescue ArgumentError    # Handle units that cancel out
	    @literal * other
	rescue NoMethodError    # Allow multiplication by a literal
	    Literal.new(@literal * other, @units)
	end

	def /(other)
	    Literal.new(@literal / other, @units / other.units)
	rescue ArgumentError    # Handle units that cancel out
	    @literal / other
	rescue NoMethodError    # Allow division by a literal
	    Literal.new(@literal / other, @units)
	end
    end
end