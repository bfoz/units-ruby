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
	    alias_method :-, :subtract
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

    def inspect
	super.inspect + ' ' + @units.inspect
    end
    def to_s
	super
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
	    result.units = @units + other.units
	elsif @units or other.units
	    result.units = @units || other.units
	end
	result
    end
    def subtract(other)
	result = self.unitsmethods_original_subtraction(other)
	if @units and other.units
	    result.units = @units - other.units
	elsif (@units or other.units)
	    result.units = @units || other.units
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
