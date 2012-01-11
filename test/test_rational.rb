require_relative 'helper'

class RationalTest < Test::Unit::TestCase
    # Prefixed with 'A' to force it to run first
    must "A_not have units before assigning units" do
	assert_raise(NoMethodError) { 1.to_r.units }
    end
    must "have units after assigning units" do
	one = 1.to_r.meters
	assert_nothing_raised { one.units }

	# All Rational instances should now respond to units
	assert_nothing_raised { 3.to_r.units }
    end

    # A literal with units is considered to be different from the same literal
    #  without units
    must "break equality" do
	assert_not_equal(3.to_r, 3.to_r.meters)
    end
    must "preserve Rational equality" do
	assert_equal(3.to_r, 3.to_r)
    end

    must "preserve Rational addition" do
	assert_equal(7.to_r, (3.to_r + 4.to_r))
    end
    must "preserve Rational subtraction" do
	assert_equal(1.to_r, (4.to_r - 3.to_r))
    end
    must "preserve Rational multiplication" do
	assert_equal(12.to_r, (3.to_r * 4.to_r))
    end
    must "preserve Rational division" do
	assert_equal(Rational(3, 4), (3.to_r / 4.to_r))
    end

    must "allow addition" do
	assert_equal(7.to_r.meters, 3.to_r.meters + 4.to_r.meters)
    end
    must "reject addition of Rational" do
	assert_raise(UnitsError) { 3.to_r.meters + 4.to_r }
	assert_raise(UnitsError) { 3.to_r + 4.to_r.meters }
    end

    must "allow subtraction" do
	assert_equal(1.to_r.meters, 4.to_r.meters - 3.to_r.meters)
    end
    must "reject subtraction of Rational" do
	assert_raise(UnitsError) { 3.to_r.meters - 4.to_r }
    end
    must "reject subtraction from Rational" do
	assert_raise(UnitsError) { 3.to_r - 4.to_r.meters }
    end

    must "allow multiplication" do
	assert_equal(12.to_r.meters(2), 3.to_r.meters * 4.to_r.meters)
    end
    must "allow multiplication by Rational" do
	assert_equal(6.to_r.meters, 2.to_r * 3.to_r.meters)
    end
    must "allow reversed multiplication by Rational" do
	assert_equal(6.to_r.inches, 2.to_r.inches * 3.to_r)
   end

    must "allow division" do
	assert_equal(Rational(3, 4), 3.to_r.meters / 4.to_r.meters)
    end
    must "allow division by Rational" do
	assert_equal(Rational(2,3).meters, 2.to_r.meters / 3.to_r)
    end
    must "allow Rational divided by Units" do
	assert_equal(Rational(2,3).meters(-1), 2.to_r / 3.to_r.meters)
    end
end
