require 'matrix'
require 'minitest/autorun'
require 'units/numeric'

describe Units::Numeric do
    let(:one)	{ Units::Numeric.new(1) }
    let(:three)	{ Units::Numeric.new(3) }
    let(:four)	{ Units::Numeric.new(4) }
    let(:seven)	{ Units::Numeric.new(7) }
    let(:twelve){ Units::Numeric.new(12) }

    let(:three_inches)	{ Units::Numeric.new(3, :inches) }
    let(:four_inches)	{ Units::Numeric.new(4, :inches) }

    let(:one_meter)	{ Units::Numeric.new(1, :meter) }
    let(:three_meters)	{ Units::Numeric.new(3, :meters) }
    let(:four_meters)	{ Units::Numeric.new(4, :meters) }
    let(:six_meters)	{ Units::Numeric.new(6, :meters) }
    let(:seven_meters)	{ Units::Numeric.new(7, :meters) }
    let(:twelve_meters)	{ Units::Numeric.new(12, :meters) }

    let(:twelve_meters2)    { Units::Numeric.new(12, Units.new(:meters, :meters)) }

    it "should claim to be a Numeric" do
	one.must_be_kind_of Numeric
    end

    describe "when constructing" do
	it "should require a value" do
	    lambda { Units::Numeric.new }.must_raise(ArgumentError)
	end

	it 'must not require a Unit' do
	    Units::Numeric.new(1).must_equal 1
	end

	it 'must accept a Unit argument' do
	    Units::Numeric.new(1, :meter).must_equal one_meter
	end

	it 'must reject a non-Numeric' do
	    ->{ Units::Numeric.new('string') }.must_raise ArgumentError
	end
    end

    describe "equality" do
	let(:three_inches)	{ Units::Numeric.new(3, :inches) }
	let(:three_meters)	{ Units::Numeric.new(3, :meters) }

	it "must equate zero-with-units and zero" do
	    0.meters.must_equal 0
	end

	it "should not equate a literal with units and a literal without units" do
	    three_meters.wont_equal 3
	end

	it "should not equate meters with inches" do
	    three_meters.wont_equal three_inches
	    three_inches.wont_equal three_meters
	end

	it "should preserve normal equality for literals without units" do
	    three.must_equal three
	    Units::Numeric.new(3).must_equal 3
	    Units::Numeric.new(3.5).must_equal 3.5
	end
    end

    describe "arithmetic without units" do
	it "should preserve integer addition" do
	    (three + four).must_equal seven
	end

	it "should preserve integer subtraction" do
	    (four - three).must_equal one
	    (three - four).must_equal -one
	end

	it "should preserve integer multiplication" do
	    (three * four).must_equal twelve
	end

	it "should preserve integer division" do
	    (twelve/four).must_equal three
	end
    end

    describe "arithmetic with like units" do
	it "should support addition" do
	    (three_meters + four_meters).must_equal seven_meters
	end

	it "should support subtraction" do
	    (four_meters - three_meters).must_equal one_meter
	    (0.meters - four_meters).must_equal -four_meters
	end

	it "should support multiplication" do
	    (3.meters * 4.meters).must_equal twelve_meters2
	end

	it "should support division" do
	    (twelve_meters / three_meters).must_equal 4
	    (0.meters / 3.meters).must_equal 0
	end

	it 'must support exponentiation' do
	    (3.meters**2).must_equal 9.meters(2)
	    (Rational(3,1).meters**2).must_equal Rational(9,1).meters(2)
	end
    end

    describe "coerced arithmetic" do
	it "multiplication" do
	    (4 * three_meters).must_equal twelve_meters
	end

	it "division" do
	    (0 / one_meter).must_equal 0
	    (0 / three_meters).must_equal 0
	    (4 / three_meters).must_equal one_meter
	    (12.0 / three_meters).must_equal four_meters
	end

	it "must divide a Rational" do
	    (Rational(2,1) / one_meter).must_equal Rational(2,1).meters(-1)
	end
    end

    describe "integer arithmetic with normal literals" do
	it 'must reject addition' do
	    ->{ 4 + three_meters }.must_raise UnitsError
	end

	it 'must reject subtraction' do
	    ->{ 4 - three_meters }.must_raise UnitsError
	end

	it 'must allow addition with zero' do
	    (0 + four_meters).must_equal four_meters
	end

	it 'must allow subtraction from zero' do
	    (0 - four_meters).must_equal -four_meters
	end

	it "should support multiplication" do
	    (three_meters * 4).must_equal twelve_meters
	    (three_meters * four).must_equal twelve_meters
	end

	it "support division" do
	    (twelve_meters / 3).must_equal four_meters
	    (one_meter / 2).must_equal 0.meters
	end
    end

    describe "arithmetic with mixed units" do
	it 'must reject addition of valid units and no units' do
	    ->{ three_meters + four }.must_raise UnitsError
	    ->{ four + three_meters }.must_raise UnitsError
	end

	it 'must reject subtraction without units' do
	    ->{ three_meters - three }.must_raise UnitsError
	    ->{ three - three_meters }.must_raise UnitsError
	end

	it 'must return a proxy object when adding mixed units' do
	    (three_meters + three_inches).must_equal Units::Addition.new(three_meters, three_inches)
	end

	it 'must return a proxy object when subtracting mixed units' do
	    (three_meters - four_inches).must_equal Units::Subtraction.new(three_meters, four_inches)
	end

	it "must return a Vector when multiplying a Vector" do
	    v = (three_meters * Vector[1,2])
	    v.must_be_kind_of Vector
	    v[0].must_equal three_meters
	    v[1].must_equal six_meters
	end

	it 'must ignore zero' do
	    (5.cm + 0.mm).must_equal 5.cm
	    (5.cm + 0.mm).must_be_instance_of Units::Numeric
	end
    end

    describe 'arithmetic with proxy objects' do
	let(:addition) { Units::Addition.new(2.inch, 3.foot) }
	let(:subtraction)   { Units::Subtraction.new(2.inch, 3.foot) }

	it 'must add an Addition proxy' do
	    (1.meter + addition).must_equal Units::Addition.new(1.meter, 2.inch, 3.foot)
	    (0.meter + addition).must_equal addition
	end

	it 'must subtract an Addition proxy' do
	    (1.meter - addition).must_equal Units.Subtraction(1.meter, 2.inch, 3.foot)
	    (0.meter - addition).must_equal Units::Subtraction.new(-2.inch, 3.foot)
	end

	it 'must add a Subtraction proxy' do
	    (1.meter + subtraction).must_equal Units::Addition.new(1.meter, subtraction)
	    (0.meter + subtraction).must_equal subtraction
	end

	it 'must subtract a Subtraction proxy' do
	    (1.meter - Units::Subtraction.new(2.inch, 3.foot)).must_equal Units::Subtraction.new(1.meter, 2.inch, -3.foot)
	end

	it 'must multiply by a proxy object' do
	    (2.meter * addition).must_equal Units::Addition.new(2.meter * 2.inch, 2.meter * 3.foot)
	    (0.meter * addition).must_equal 0.meter
	end

	it 'must divide by a proxy object' do
	    (4.meter / Units::Addition.new(1.inch, 2.foot)).must_equal Units::Division.new(4.meter, Units::Addition.new(1.inch, 2.foot))
	    (0.meter / Units::Addition.new(1.inch, 2.foot)).must_equal 0
	end
    end

    describe "comparison" do
	describe "spaceship" do
	    it "must spaceship with like units" do
		(three_meters <=> four_meters).must_equal -1
		(three_meters <=> three_meters).must_equal 0
		(four_meters <=> three_meters).must_equal 1
	    end

	    it "must spaceship with unlike units" do
		(three_meters <=> three_inches).must_equal 1
		(three_inches <=> three_meters).must_equal -1
	    end

	    it "must spaceship with unitless literals" do
		(three_meters <=> 4).must_equal -1
		(three_meters <=> 3).must_equal 0
		(four_meters <=> 3).must_equal 1
	    end

	    it "must reverse spaceship with unitless literals" do
		(3 <=> four_meters).must_equal -1
		(3 <=> three_meters).must_equal 0
		(4 <=> three_meters).must_equal 1
	    end
	end
    end

    it "must square root" do
	Math.sqrt(three_meters*three_meters).must_equal three_meters
    end

    it "should have an inspect method" do
	assert_equal('1 meter', one_meter.inspect)
	assert_equal(1, one);
    end
    it "should have a to_s method that returns only the literal's to_s" do
	assert_equal('1', one_meter.to_s)
    end

    describe "when converting to other units" do
	it "must convert to different units" do
	    one_meter.to_inches.must_equal 39.3701.inches
	end

	it "must do nothing when converting to identical units" do
	    one_meter.to_meters.must_equal one_meter
	end

	it "must handle prefix-only conversions" do
	    one_meter.to_millimeters.must_equal 1000.mm
	end

	it "must handle mixed prefix conversions" do
	    100.cm.to_inches.must_equal 39.3701.inches
	    100.inches.to_centimeters.must_equal 254.cm
	end

	it "must handle converting to abbreviated units" do
	    100.cm.to_mm.must_equal 1000.mm
	end

	it 'must adopt the new units when it has no units' do
	    Units::Numeric.new(5).meters.must_equal 5.meters
	end

	it "must reject invalid target units" do
	    -> { 100.cm.to_foo }.must_raise NoMethodError
	end

	it 'must have a conversion method' do
	    100.cm.to('inches').must_equal 39.3701.inches
	    100.cm.to(:inches).must_equal 39.3701.inches
	    100.cm.convert_to(:inches).must_equal 39.3701.inches
	end

	it 'must have a conversion methods that accepts a Units argument' do
	    100.cm.to(Units.new(:inches)).must_equal 39.3701.inches
	end
    end

    describe 'when converting to other units with the per_ prefix' do
	it 'must add the correct units to a literal' do
	    3.per_second.must_equal 3.second(-1)
	    4.per_second(2).must_equal 4.second(-2)
	end

	it 'must add the correct units to existing units' do
	    three_meters.per_second.must_equal Units::Numeric.new(3, {meters:1, second:-1})
	    three_meters.per_second(2).must_equal Units::Numeric.new(3, {meters:1, second:-2})
	end

	it 'must cancel units when appropriate' do
	    three_meters.per_meter.must_equal Units::Numeric.new(3)
	end
    end

    describe 'when converting to other units without the to_ prefix' do
	it 'must convert to different units' do
	    one_meter.inches.must_equal 39.3701.inches
	end

	it 'must do nothing when converting to identical units' do
	    one_meter.meters.must_equal one_meter
	end

	it 'must handle prefix-only conversions' do
	    one_meter.millimeters.must_equal 1000.mm
	end

	it 'must handle mixed prefix conversions' do
	    100.cm.inches.must_equal 39.3701.inches
	    100.inches.centimeters.must_equal 254.cm
	end

	it 'must handle converting to abbreviated units' do
	    100.cm.mm.must_equal 1000.mm
	end

	it 'must reject invalid target units' do
	    -> { 100.cm.foo }.must_raise NoMethodError
	end
    end

    describe 'when asked about its units' do
	it 'must be degrees' do
	    90.degrees.degrees?.must_equal true
	end

	it 'must be meters' do
	    1.meter.meters?.must_equal true
	end

	it 'must be inches' do
	    1.inch.inch?.must_equal true
	end
    end
end
