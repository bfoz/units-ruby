require_relative 'units_mixin'

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
    
    # http://en.wikipedia.org/wiki/International_System_of_Units
    SI_UNITS = [:meter, :gram, :second, :ampere, :kelvin, :candela, :mole]
    SI_DERIVED = [
	:hertz,	:radian,    :steradian,	:newton,    :pascal,	:joule,
	:watt,	:coulomb,   :volt,	:farad,	    :ohm,	:siemens,
	:weber,	:tesla,	    :henry,	:celsius,   :lumen,	:lux,
	:gray,	:sievert,   :katal,	:becquerel
    ]
    
    # http://en.wikipedia.org/wiki/United_States_customary_units
    US_CUSTOMARY_AREA_UNITS = [:acre, :section, :township]
    US_CUSTOMARY_INTERNATIONAL_UNITS = [:point, :pica, :inch, :foot, :yard, :mile]
    US_CUSTOMARY_MASS_UNITS = [
	:grain, :dram, :ounce, :pound, :hundredweight, :long_hundredweight,
	:short_ton, :long_ton, :pennyweight, :troy_ounce, :troy_pound
    ]
    US_CUSTOMARY_NAUTICAL_UNITS = [:fathom, :cable, :nautical_mile]
    US_CUSTOMARY_SURVEY_UNITS = [
	:link, :survey_foot, :rod, :chain,
	:furlong, :statute_mile, :league
    ]
    US_CUSTOMARY_TEMPERATURE_UNITS = [:fahrenheit, :rankine]
    US_CUSTOMARY_VOLUME_UNITS = [
	:acre_foot, :minim, :fluid_dram, :teaspoon, :tablespoon, :fluid_ounce,
	:jigger, :gill, :cup, :pint, :quart, :barrel, :hogshead
    ]
    US_CUSTOMARY_UNITS = US_CUSTOMARY_AREA_UNITS +
			 US_CUSTOMARY_INTERNATIONAL_UNITS +
			 US_CUSTOMARY_MASS_UNITS +
			 US_CUSTOMARY_NAUTICAL_UNITS +
			 US_CUSTOMARY_SURVEY_UNITS +
			 US_CUSTOMARY_TEMPERATURE_UNITS +
			 US_CUSTOMARY_VOLUME_UNITS

    ABBREVIATIONS = {
	:mm => 'millimeter', :cm => 'centimeter', :km => 'kilometer',
    }
    ABBREVIATION_EXP = Regexp.new('\A(?<abbreviation>' + ABBREVIATIONS.keys.join('|') + ')')

    UNITS = SI_UNITS + SI_DERIVED + US_CUSTOMARY_UNITS + [:degrees]

    BASE_CAPTURE = '(?<base>' + UNITS.each {|u| u.to_s }.join('|') + ')'
    PREFIX_CAPTURE = '(?<prefix>' + PREFIXES.keys.each {|u| u.to_s }.join('|') + ')?'
    PARSER_EXP = Regexp.new('\A'+PREFIX_CAPTURE+BASE_CAPTURE+'(s|es)?')

    def self.is_valid_unit?(s)
	s = s.is_a?(String) ? s : s.to_s
	return true if ABBREVIATION_EXP =~ s
	m = PARSER_EXP.match(s)
	m and UNITS.include?( m[:base].to_sym )
    end

    def self.parse_symbol(s)
	m = ABBREVIATION_EXP.match(s.is_a?(String) ? s : s.to_s)
	s = ABBREVIATIONS[m[:abbreviation].to_sym] if m and ABBREVIATIONS.include?(m[:abbreviation].to_sym)
	m = PARSER_EXP.match(s.is_a?(String) ? s : s.to_s)
	if m and UNITS.include?(m[:base].to_sym)
	    Hash[m.names.map {|n| [n.to_sym, m[n] ? m[n].to_sym : nil] }]
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

    def inspect
	prefix = ''
	s = ''
	@units.each do |k,v|
	    if (k == :prefix) and v and (v != 0)
		prefix = PREFIXES.key(v).to_s
	    else
		s << k.to_s
		s << "^#{v}" if (v > 1) or (v < 0)
	    end
	end
	prefix+s
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

    def inspect
	@literal.inspect + ' ' + @units.inspect
    end

    # Both the values and the units must match for two numbers to be considered equal
    #  ie. 3.meters != 3.inches != 3
    def ==(other)
	other.respond_to?(:units) and (@units == other.units) and (@literal == other.literal)
    end

    def +(other)
	LiteralWithUnits.new(@literal + other, @units + other.units)
    rescue NoMethodError
	LiteralWithUnits.new(@literal + other, @units)
    end

    def -(other)
	LiteralWithUnits.new(@literal - other, @units - other.units)
    rescue NoMethodError
	LiteralWithUnits.new(@literal - other, @units)
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
