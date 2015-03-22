module NumericMixin
    # Trap missing method calls and look for methods that look like unit names
    def method_missing(name, *args, &block)
	if !block_given?
	    units = if Units.valid_unit?(name)
		Units.new(args.empty? ? name : {name => args[0]})
	    elsif (name.to_s =~ /^per_(.+)$/) and Units.valid_unit?($1)
		Units.new(args.empty? ? {$1 => -1} : {$1 => -args[0]})
	    else
		super if defined?(super)
	    end

	    # Float and Fixnum need to be handled specially because they're
	    #  treated as literals by the interpreter. Specifically, all
	    #  literals with the same value are considered to be the same
	    #  instance. Consequently, any instance variable (such as @units)
	    #  added to a literal becomes available to all literals of the
	    #  same value.
	    if self.is_a?(Fixnum) or self.is_a?(Float)
		Units::Numeric.new(self, units)	# Create a new wrapper object
	    else
		# Check that the class hasn't already been patched
		#  Numeric's subclasses are patched here, instead of at load-time,
		#  to automatically support any future Numeric subclasses without
		#  requiring changes to this module
		@units = units
		self.class.send(:prepend, UnitsMixin) unless self.kind_of?(UnitsMixin)
		self
	    end
	else
	    super if defined?(super)
	end
    end
end