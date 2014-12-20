module UnitsMixin
    attr_reader :units	# Returns the Units object

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
    def ==(other)
	other_units = units_for_other(other)
	if @units and other_units
	    (@units == other_units) and super(other)
	elsif @units or other_units
	    false
	else
	    super(other)
	end
    end

    def +(other)
	if other.is_a? Units::Operator
	    Units.Addition(self) + other
	else
	    begin
		result = super(value_for_other(other))
		apply_result_units(result, units_op(:+, units_for_other(other)))
	    rescue UnitsError
		Units.Addition(self, other)
	    end
	end
    end

    def -(other)
	if other.is_a? Units::Operator
	    Units.Subtraction(self, other)
	else
	    begin
		result = super(value_for_other(other))
		apply_result_units(result, units_op(:-, units_for_other(other)))
	    rescue UnitsError
		Units.Subtraction(self, other)
	    end
	end
    end

    def *(other)
	if other.is_a? Units::Operator
	    other * self
	else
	    result = super(value_for_other(other))
	    apply_result_units(result, units_op(:*, units_for_other(other)))
	end
    end

    def /(other)
	if other.is_a? Units::Operator
	    Units::Division.new(self, other)
	else
	    result = super(value_for_other(other))

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

    def **(power)
	result = super(power)
	apply_result_units(result, units ? (units ** power) : nil)
    end

    # @group Conversion

    # Convert to the desired units
    # @param units [Units]	the desired units to convert to
    # @return [Numeric]
    def convert_to(units)
	units = units.is_a?(Units) ? units : Units.new(units)
	raise UnitsError, "Can't convert '#{@units}' to: #{units}" unless @units.valid_conversion?(units)
	return self if @units == units
	@units.convert(self, units).tap {|value| value.instance_variable_set(:@units, units)}
    end
    alias to convert_to

    # @endgroup

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
