require_relative '../units'
require_relative 'addition'
require_relative 'division'
require_relative 'subtraction'

class Units
    class Numeric < Numeric
	attr_reader :units, :value

	def initialize(value, units=nil)
	    @value = value
	    @units = (units.is_a?(Units) ? units : Units.new(units)) if units
	end

	# Handle conversion methods (to_*) and pass everything else to the wrapped value
	def method_missing(id, *args)
	    # Check this before valid_conversion? because valid_conversion? has low standards
	    if (id.to_s =~ /(.+)\?$/) and Units.valid_unit?($1)
		@units.is_a?($1)
	    elsif @units.valid_conversion?(id)
		units = Units.new(id)
		(@units == units) ? self : self.class.new(@units.convert(@value, id), units)
	    elsif (id.to_s =~ /^to_(.+)$/) and Units.valid_unit?($1)
		units = Units.new($1)
		return self if @units == units
		self.class.new(@units.convert(@value, $1), units)
	    else
		@value.send(id, *args)
	    end
	end

	def respond_to_missing?(name, include_private = false)
	    # Check this before valid_conversion? because valid_conversion? has low standards
	    if (name.to_s =~ /(.+)\?$/) and Units.valid_unit?($1)
		true
	    elsif @units and @units.valid_conversion?(name)
		true
	    elsif (name.to_s =~ /^to_(.+)$/) and Units.valid_unit?($1)
		true
	    else
		super
	    end
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

	# Convert other into something that can work with a {Numeric}
	def coerce(other)
	    case other
		when Fixnum then [self.class.new(other), self]
		when Float  then [self.class.new(other), self]
		else
		    other.class.send(:include, UnitsMixin) unless other.kind_of?(UnitsMixin)
		    [other, self]
	    end
	end

	# Both the values and the units must match for two numbers to be considered equal
	#  ie. 3.meters != 3.inches != 3
	# However, 0.units == 0 is a special case to avoid breaking any conditionals
	# that attempt to avoid dividing by zero
	def eql?(other)
	    if other.respond_to?(:units)
		(@units == other.units) and (@value == other.value)
	    elsif other == 0
		@value == other
	    else
		(@units == nil) and (@value == other)
	    end
	end
	alias == eql?

	def <=>(other)
	    if other.kind_of? Numeric
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
	    return other if self.zero?

	    case other
		when Units::Addition	then Units::Addition.new(self, *other.operands)
		when Units::Operator	then Units.Addition(self, other)
		else op(:+, other)
	    end
	end

	def -(other)
	    case other
		when Units::Operator	then Units::Subtraction.new(self, other)
		else op(:-, other)
	    end
	end

	def *(other)
	    case other
		when Units::Operator	then other * self
		else op(:*, other)
	    end
	end

	def /(other)
	    return self if self.zero?

	    case other
		when Units::Operator	then Units::Division.new(self, other)
		else op(:/, other)
	    end
	end

	def **(power)
	    self.class.new(@value ** power, @units ? (@units ** power) : nil)
	end
	# @endgroup

	private

	# Generic operator handler
	def op(sym, other)
	    if other.kind_of? Numeric
		begin
		    result_units = @units ? @units.send(sym, other.units) : ((:/ == sym) && (0 == @value) ? nil : other.units)
		rescue UnitsError
		    case sym
			when :+ then Units::Addition.new(self, other)
			when :- then Units::Subtraction.new(self, other)
		    end
		else
		    self.class.new(@value.send(sym, other.value), result_units)
		end
	    elsif other.respond_to? :map
		other.map {|a| self.send(sym, a)}
	    else
		self.class.new(@value.send(sym, other), @units ? (@units.send(sym, other.units)) : other.units)
	    end
	rescue UnitsError
	    raise
	rescue ArgumentError    # Handle units that cancel out
	    @value.send(sym, other.value)
	rescue NoMethodError
	    self.class.new(@value.send(sym, other), @units)
	end
    end
end
