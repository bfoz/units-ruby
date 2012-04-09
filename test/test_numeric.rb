require_relative 'helper'

class NumericTest < Test::Unit::TestCase
    # Prefixed with 'A' to force it to run first
    must "A_not have units before assigning units" do
	assert_raise(NoMethodError) { 1.units }
    end

    must "allow prefixes" do
	assert_nothing_raised do
	    1.millimeter
	end
    end

    # A literal with units is considered to be different from the same literal
    #  without units
    must "break equality" do
	assert_not_equal(3, 3.meters)
    end
    must "preserve Literal equality" do
	assert_equal(3, 3)
    end

    must "preserve Literal addition" do
	assert_equal(7.to_r, (3.to_r + 4.to_r))
    end
    must "preserve Literal subtraction" do
	assert_equal(1.to_r, (4.to_r - 3.to_r))
    end
    must "preserve Literal multiplication" do
	assert_equal(12.to_r, (3.to_r * 4.to_r))
    end
    must "preserve Literal division" do
	assert_equal(Rational(3, 4), (3.to_r / 4.to_r))
    end

    must "allow addition" do
	assert_equal(7.meters, 3.meters + 4.meters)
    end
    must "reject mixed units when adding" do
	assert_raise(UnitsError) { 3.meters + 3 }
    end
    must "reject mixed units when reverse adding" do
	assert_raise(UnitsError) { 3 + 3.meters }
    end

    must "allow subtraction" do
	assert_equal(1.meters, 4.meters - 3.meters)
    end
    must "reject mixed units when subtracting" do
	assert_raise(UnitsError) { 3.meters - 4 }
    end
    must "reject mixed units when reverse subtracting" do
	assert_raise(UnitsError) { 3 - 4.meters }
    end

    must "allow multiplication" do
	assert_equal(12.meters(2), 3.meters * 4.meters)
    end
    must "allow multiplication by Literal" do
	assert_equal(6.meters, 2.meters * 3)
    end
    must "allow reverse multiplication by Literal" do
	assert_equal(6.meters, 2 * 3.meters)
    end

    must "allow division" do
	assert_equal(5, 10.meters / 2.meters)
    end
    must "allow division by Literal" do
	assert_equal(5.meters, 10.meters / 2)
    end
    must "allow Literal divided by Units" do
	assert_equal(5.meters(-1), 10 / 2.meters)
    end
end
