# Add an exception class for unsupported operations
class UnitsError < ArgumentError
end

class Units
    attr_reader :units	# Returns the units hash

    PREFIXES = {
	:yocto => -24,	:zepto => -21,	:atto  => -18,	:femto => -15,
	:pico  => -12,	:nano  =>  -9,	:micro =>  -6,	:milli =>  -3,
	:centi =>  -2,	:deci  =>  -1,	:deca  =>   1,	:hecto =>   2,
	:kilo  =>   3,	:mega  =>   6,	:giga  =>   9,	:tera  =>  12,
	:peta  =>  15,	:exa   =>  18,	:zetta =>  21,	:yotta =>  24,
    }
    UNITS = [:meter, :inch]

    BASE_CAPTURE = '(?<base>' + UNITS.each {|u| u.to_s }.join('|') + ')'
    PREFIX_CAPTURE = '(?<prefix>' + PREFIXES.keys.each {|u| u.to_s }.join('|') + ')?'
    PARSER_EXP = Regexp.new('\A'+PREFIX_CAPTURE+BASE_CAPTURE+'(s|es)?')

    def self.is_valid_unit?(s)
	m = PARSER_EXP.match(s.is_a?(String) ? s : s.to_s)
	m and UNITS.include?( m[:base].to_sym )
    end

    def self.parse_symbol(s)
	m = PARSER_EXP.match(s.is_a?(String) ? s : s.to_s)
	if m and UNITS.include?(m[:base].to_sym)
	    names = m.names.map {|n| n.to_sym}
	    Hash[*names.zip(m.captures).flatten]
	else
	    nil
	end
    end

    def initialize(*args)
	raise ArgumentError, "Units cannot be nil" if args.select! {|k| k}

	# Convert Strings to Symbols and Symbols to Hashes
	args.map! {|a| a.is_a?(String) ? a.to_sym : a }
	args.map! {|a| a.is_a?(Symbol) ? {a => 1} : a }

	# Merge all hashes into one
    	args = args.reduce({}) { |h, a| h.merge(a) {|k,o,n| o+n} }

	# At this point, args must be a Hash, otherwise there's a problem
	raise ArgumentError, "Couldn't make a Hash" unless args.is_a? Hash

	# Remove any keys with value == 0
	args = args.select {|key, value| value != 0}

	# Check that all keys are valid units and parse them
	prefix = args[:prefix] ? args.delete(:prefix) : 0
	args = args.inject({}) do |h,(k,v)|
	    raise UnitsError, "Invalid Units" unless parsed = Units.parse_symbol(k)
	    h[parsed[:base]] = v
	    prefix += PREFIXES[parsed[:prefix]] if parsed[:prefix]
	    h
	end

	# Can't have units without any units
	raise ArgumentError, "Empty units" if args.empty?

	# Restore the :prefix key if it's non-zero
	args[:prefix] = prefix if prefix != 0

	# Everything checked out, so use the new units hash
	@units = args
    end

    # Create a clone with negated units
    def invert
	Units.new(@units.inject({}) { |h,(k,v)| h[k] = -v; h })
    end

    # Define comparison operators
    def ==(other)
	if other
	    @units == other.units
	else
	    false
	end
    end
    def !=(other)   # Define inequality as the opposite of equality
	!(self == other)
    end
    def ===(other)
	@units == other.units
    end

    def +(other)
	raise UnitsError, "Addition requires matching units" unless (self == other)
	Units.new(@units)
    end
    def -(other)
	raise UnitsError, "Subtraction requires matching units" unless (self == other)
	Units.new(@units)
    end
    def *(other)
	Units.new(@units.merge(other ? other.units : {}) {|k, left, right| left + right })
    end
    def /(other)
	other ? (self * other.invert) : self
    end
end

module UnitsMixin
    attr_reader :units	# Returns the Units object

    def self.included(base)
	# Patch the including class to intercept various operators
	base.instance_eval do
	    alias_method :unitsmethods_original_equality, :==
	    alias_method :==, :equality
	    alias_method :unitsmethods_original_addition, :+
	    alias_method :+, :add
	    alias_method :unitsmethods_original_subtraction, :-
	    alias_method :-, :subtact
	    alias_method :unitsmethods_original_multiply, :*
	    alias_method :*, :multiply
	    alias_method :unitsmethods_original_division, :/
	    alias_method :/, :divide
	end
    end

    # FIXME Get rid of this method. Changing units shouldn't be allowed.
    def units=(args)
	@units = args.is_a?(Units) ? args : Units.new(args)
    end

    # Both value and units must match for two numbers to be considered equal
    #  ie. 3.meters != 3.inches != 3
    def equality(other)
	if @units and other.units
	    (@units == other.units) and unitsmethods_original_equality(other)
	elsif @units or other.units
	    false
	else
	    unitsmethods_original_equality(other)
	end
    end

    def add(other)
	result = self.unitsmethods_original_addition(other)
	if @units and other.units
	    if @units == other.units
		result.units = @units + other.units
	    else
		raise UnitsError, "Addition requires matching units"
	    end
	elsif @units or other.units
	    raise UnitsError, "Can't add a number with units to a literal"
	end
	result
    end
    def subtact(other)
	result = self.unitsmethods_original_subtraction(other)
	if @units and other.units
	    if @units == other.units
		result.units = @units - other.units
	    else
		raise UnitsError, "Subtract requires matching units"
	    end
	elsif (@units or other.units) and (@units != other.units)
	    raise UnitsError, "Can't subtract a number with units from a literal"
	end
	result
    end
    def multiply(other)
	result = unitsmethods_original_multiply(other)
	if @units and other.units
	    result.units = @units * other.units
	elsif @units or other.units
	    result.units = (@units or other.units)
	end
	result
    end
    def divide(other)
	result = unitsmethods_original_division(other)

	other_units = other.respond_to?(:units) ? other.units : nil
	if @units and other_units
	    begin
		result.units = @units / other.units
	    rescue ArgumentError
	    end
	elsif @units or other_units
	    result.units = (@units or other.units.invert)
	end
	result
    end
end

class LiteralWithUnits
    attr_reader :literal, :units

    def initialize(literal, units)
	@literal = literal
	@units = units.is_a?(Units) ? units : Units.new(units)
    end

    # Pass most everything through to the literal
    def method_missing(id, *args)
	@literal.send(id, *args)
    end

    # Both the values and the units must match for two numbers to be considered equal
    #  ie. 3.meters != 3.inches != 3
    def ==(other)
	other.respond_to?(:units) and (@units == other.units) and (@literal == other.literal)
    end

    def +(other)
	LiteralWithUnits.new(@literal + other, @units + other.units)
    rescue NoMethodError
	raise UnitsError, "Can't add literal without units"
    end

    def -(other)
	LiteralWithUnits.new(@literal - other, @units - other.units)
    rescue NoMethodError
	raise UnitsError, "Can't subtract literals without units"
    end

    def *(other)
	LiteralWithUnits.new(@literal * other, @units * other.units)
    rescue ArgumentError    # Handle units that cancel out
	@literal * other
    rescue NoMethodError    # Allow multiplication by a literal
	LiteralWithUnits.new(@literal * other, @units)
    end

    def /(other)
	LiteralWithUnits.new(@literal / other, @units / other.units)
    rescue ArgumentError    # Handle units that cancel out
	@literal / other
    rescue NoMethodError    # Allow division by a literal
	LiteralWithUnits.new(@literal / other, @units)
    end

end

# Trap missing method calls and look for methods that look like unit names
module NumericMixin
    def method_missing(id, *args, &block)
	if Units.is_valid_unit?(id)
	    units = Units.new(args.empty? ? id : {id => args[0]})

	    # Float and Fixnum need to be handled specially because they're
	    #  treated as literals by the interpreter. Specifically, all
	    #  literals with the same value are considered to be the same
	    #  instance. Consequently, any instance variable (such as @units)
	    #  added to a literal becomes available to all literals of the
	    #  same value.
	    if self.is_a?(Fixnum) or self.is_a?(Float)
		LiteralWithUnits.new(self, units)	# Create a new wrapper object
	    else
		# Check that the class hasn't already been patched
		#  Numeric's subclasses are patched here, instead of at load-time,
		#  to automatically support any future Numeric subclasses without
		#  requiring changes to this module
		unless self.kind_of?(UnitsMixin)
		    self.class.send(:include, UnitsMixin)
		end

		@units = units
		self
	    end
	else
	    super if defined?(super)
	end
    end
end

# Monkey patch Numeric with a module so that super will work properly in the
#   patched methods
class Numeric
    include NumericMixin
end
