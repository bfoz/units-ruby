require_relative 'numeric'
require_relative 'units_mixin'
require_relative 'units/constants'
require_relative 'units/numeric'
require_relative 'units/math'

# Add an exception class for unsupported operations
UnitsError = Class.new(ArgumentError)

class Units
    attr_reader :units	# Returns the units hash

    def self.valid_unit?(s)
	s = s.is_a?(String) ? s : s.to_s
	return true if ABBREVIATION_EXP =~ s
	m = PARSER_EXP.match(s)
	m and UNITS.include?( m[:base].to_sym )
    end

    # Trap missing method calls and look for methods that look like unit names
    def self.method_missing(id, *args, &block)
	if Units.valid_unit?(id)
	    units = Units.new(args.empty? ? id : {id => args[0]})
	else
	    super if defined?(super)
	end
    end

    # @param [String,Symbol] symbol The string, or symbol, to parse
    # @return [Hash]
    def self.parse_symbol(s)
	m = ABBREVIATION_EXP.match(s.to_s)
	s = ABBREVIATIONS[m[:abbreviation].to_sym] if m and ABBREVIATIONS.include?(m[:abbreviation].to_sym)
	m = PARSER_EXP.match(s.to_s)
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
	    raise UnitsError, "Invalid Units: '#{k}'" unless parsed = Units.parse_symbol(k)
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

    # @return {String} The unit abbreviation
    def to_abbreviation
	prefix = ''
	s = ''
	@units.each do |k,v|
	    if (k == :prefix) and v and (v != 0)
		prefix = PREFIX_ABBREVIATIONS[PREFIXES.key(v)]
	    else
		s << UNIT_ABBREVIATIONS[k]
		s << "^#{v}" if (v > 1) or (v < 0)
	    end
	end
	prefix+s
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
    alias_method :to_s, :inspect

    # Override to intercept and check against the current units
    def is_a?(name)
	target = Units.parse_symbol(name)
	(target && @units.include?(target[:base])) || super(name)
    end

    # Create a clone with negated units
    def invert
	Units.new(@units.inject({}) {|h,(k,v)| h[k] = -v; h })
    end

    # Convert a value to different units
    # @param [Numeric]		value	The value to convert
    # @param [String,Symbol]	target	The units to convert the value to
    def convert(value, target)
	target_unit = Units.parse_symbol(target)

	target_base = target_unit[:base]
	target_conversions = BASE_CONVERSIONS[target_base];
	raise ArgumentError, "No conversions to '#{target_base}'" unless target_conversions

	source_prefix = self.prefix || 0
	target_prefix = PREFIXES[target_unit[:prefix]] || 0
	prefix_multiplier = 10**(source_prefix - target_prefix)

	conversion_factors = @units.select {|k,v| target_conversions.include?(k) }
	base_multiplier = conversion_factors.map {|k,v| target_conversions[k]**v }.reduce(1) {|accumulator, factor| accumulator * factor }

	value * prefix_multiplier * base_multiplier
    end

    # Check that the given conversion is valid
    # @param [String,Symbol]	target	The units to check
    # @return [Bool]	True if the target units are a valid conversion
    def valid_conversion?(target)
	target_unit = Units.parse_symbol(target)
	return false unless target_unit
	target_base = target_unit[:base]
	return true if @units.keys.include?(target_base)
	conversion_hash = BASE_CONVERSIONS[target_base]
	conversion_hash && ((@units.keys & conversion_hash.keys).size != 0)
    end

# @group Accessors
    # @return [Fixnum]	The prefix exponent, or nil if the exponent is zero
    def prefix
	@units[:prefix]
    end
# @endgroup

# @group Operators

    # Define comparison operators
    def eql?(other)
	self.class.equal?(other.class) && @units == other.units
    end
    alias == eql?

    def !=(other)   # Define inequality as the opposite of equality
	!(self == other)
    end
    def ===(other)
	@units == other.units
    end

    def <=>(other)
	self.eql?(other) ? 0 : nil
    end

    def +(other)
	raise UnitsError, "Addition requires matching units: #{self} != #{other}" unless (self == other) || !other
	Units.new(@units)
    end
    def -(other)
	raise UnitsError, "Subtraction requires matching units: #{self} != #{other}" unless (self == other) || !other
	Units.new(@units)
    end
    def *(other)
	Units.new(@units.merge(other ? other.units : {}) {|k, left, right| left + right })
    end
    def /(other)
	other ? (self * other.invert) : self
    end

    # Raise the units to the power of power
    # @param power [Number] the power to raise everything to
    def **(power)
	Units.new(@units.inject({}) {|h,(unit,exponent)| h[unit] = power * exponent; h })
    end

# @endgroup

    # Return the units for the square root of the receiver
    # @return [Units]
    def square_root
	Units.new(@units.inject({}) {|h,(k,v)| h[k] = v/2; h })
    end
end
