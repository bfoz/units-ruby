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
	    alias_method :unitsmethods_original_exponent, :**
	    alias_method :**, :exponent
	end
    end

    # FIXME Get rid of this method. Changing units shouldn't be allowed.
    def units=(args)
	@units = (!args or args.is_a?(Units)) ? args : Units.new(args)
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
	other_units = units_for_other(other)
	if @units and other_units
	    (@units == other_units) and unitsmethods_original_equality(other)
	elsif @units or other_units
	    false
	else
	    unitsmethods_original_equality(other)
	end
    end

    def add(other)
	result = self.unitsmethods_original_addition(value_for_other(other))
	apply_result_units(result, units_op(:+, units_for_other(other)))
    end

    def subtract(other)
	result = self.unitsmethods_original_subtraction(value_for_other(other))
	apply_result_units(result, units_op(:-, units_for_other(other)))
    end

    def multiply(other)
	result = unitsmethods_original_multiply(value_for_other(other))
	apply_result_units(result, units_op(:*, units_for_other(other)))
    end

    def divide(other)
	if other.is_a? Units::Operator
	    Units::Division.new(self, other)
	else
	    result = unitsmethods_original_division(value_for_other(other))

	    other_units = units_for_other(other)
	    if @units and other_units
		begin
		    result_units = @units / other_units
		rescue ArgumentError
		end
	    elsif @units or other_units
		result_units = (0 == result) ? @units : (@units or other_units.invert)
	    end

	    apply_result_units(result, result_units)
	end
    end

    def exponent(power)
	result = unitsmethods_original_exponent(power)
	apply_result_units(result, units ? (units ** power) : nil)
    end

    private

    def apply_result_units(result, result_units)
	if result.respond_to?(:units=)
	    result.units = result_units
	    result
	elsif result_units
	    Units::Numeric.new(result, result_units)
	else
	    result
	end
    end

    def units_for_other(other)
	other.respond_to?(:units) ? other.units : nil
    end

    def units_op(op, other_units)
	if @units and other_units
	    @units.send(op, other_units)
	elsif @units or other_units
	    @units or other_units
	end
    end

    def value_for_other(other)
	other.kind_of?(Units::Numeric) ? other.value : other
    end
end
