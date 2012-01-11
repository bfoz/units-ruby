require_relative 'helper'

class UnitsTest < Test::Unit::TestCase
    must "accept valid units" do
	Units::UNITS.each {|unit| assert(Units.is_valid_unit?(unit)) }
    end
    # Also tests equality
    must "accept valid units hash" do
	assert_equal(Units.new({:meters => 1}), Units.new(:meters => 1))
	# Test hashification
	assert_equal(Units.new({:meters => 1, :inches => 1}),
		     Units.new(:meters => 1, :inches => 1))
	# Test arrayification
	assert_equal(Units.new({:meters => 1, :inches => 1}),
		     Units.new(:meters, :inches))
    end
    must "accept valid units string" do
	Units::UNITS.each {|unit| assert_equal(Units.new({unit => 1}), Units.new(unit.to_s)) }
    end
    # Also verifies that exponents default to 1
    must "accept valid units symbol" do
	Units::UNITS.each {|unit| assert_equal(Units.new({unit => 1}), Units.new(unit)) }
    end

    must "reject invalid units" do
	assert(! Units.is_valid_unit?(:foo) )
    end

    must "reject nil units" do
	assert_raise(ArgumentError) { Units.new(nil) }
    end
    must "reject zero units hash" do
	assert_raise(ArgumentError) { Units.new({:meters => 0}) }
    end
    must "reject empty units hash" do
	assert_raise(ArgumentError) { Units.new({}) }
    end
    must "reject invalid units hash" do
	assert_raise(UnitsError) { Units.new({:foo => 1}) }
    end
    must "reject empty units string" do
	assert_raise(UnitsError) { Units.new('') }
    end
    must "reject invalid units string" do
	assert_raise(UnitsError) { Units.new('foo') }
    end
    must "reject invalid units symbol" do
	assert_raise(UnitsError) { Units.new(:foo) }
    end

    must "ignore hash keys with zero value" do
	units = Units.new(:meters)
	assert_equal(units, Units.new(:meters => 1, :inches => 0))
	assert_not_equal(units, Units.new(:meters => 1, :inches => 1))
    end

    must "Equal units must be equal" do
	assert_equal(Units.new(:meters), Units.new(:meters))
    end
    must "Unequal units must be unequal" do
	assert_not_equal(Units.new(:meters), Units.new(:inches))
    end
    must "Case equality must work" do
	assert(Units.new(:meters) === Units.new(:meters))
	assert(!(Units.new(:meters) === Units.new(:inches)))
    end
    must "not equal nil" do
	assert_not_equal(Units.new(:meters), nil)
    end
end
