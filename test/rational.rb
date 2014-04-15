require 'minitest/autorun'
require 'units/numeric'

describe Rational do
    subject { Rational(10,2).meters }

    let(:zero_meters)	{ Rational(0).meters }
    let(:one_meter)	{ Rational(1).meter }
    let(:three_meters)	{ Rational(3).meter }
    let(:four_meters)	{ Rational(4).meter }
    let(:seven_meters)	{ Rational(7).meter }
    let(:twelve_meters)	{ Rational(12).meter }

    let(:twelve_meters2)    { Rational(12).meters(2) }

    it 'must be a mixin' do
	subject.must_be_kind_of UnitsMixin
	zero_meters.must_be_kind_of UnitsMixin
    end

    it 'must not break zero' do
	Rational(0).zero?.must_equal true
	Rational(1).zero?.must_equal false
    end

    it 'must not be zero' do
	one_meter.zero?.must_equal false
	one_meter.wont_equal 0
    end

    describe 'arithmetic without units' do
	let (:one)	{ Rational(1) }
	let (:three)	{ Rational(3) }
	let (:four)	{ Rational(4) }
	let (:seven)	{ Rational(7) }
	let (:twelve)	{ Rational(12) }

	it 'must preserve addition' do
	    (three + four).must_equal seven
	end

	it 'must preserve subtraction' do
	    (four - three).must_equal one
	    (three - four).must_equal -one
	end

	it 'must preserve multiplication' do
	    (three * four).must_equal twelve
	end

	it 'must preserve division' do
	    (twelve/four).must_equal three
	end
    end

    describe 'arithmetic with like units' do
	it 'must support addition' do
	    (three_meters + four_meters).must_equal seven_meters
	end

	it 'must support subtraction' do
	    (four_meters - three_meters).must_equal one_meter
	    (zero_meters - four_meters).must_equal -four_meters
	end

	it 'must support multiplication' do
	    (three_meters * four_meters).must_equal twelve_meters2
	end

	it 'must support division' do
	    (twelve_meters / three_meters).must_equal 4
	    (zero_meters / three_meters).must_equal 0
	end

	it 'must support exponentiation' do
	    (Rational(3,1).meters**2).must_equal Rational(9,1).meters(2)
	end
    end

    describe 'arithmetic with proxy objects' do
	let(:addition) { Units::Addition.new(2.inch, 3.foot) }
	let(:subtraction)   { Units::Subtraction.new(2.inch, 3.foot) }

	it 'must add an Addition proxy' do
	    (one_meter + addition).must_equal Units::Addition.new(one_meter, 2.inch, 3.foot)
	    (zero_meters + addition).must_equal (zero_meters + addition)
	end

	it 'must subtract an Addition proxy' do
	    (one_meter - addition).must_equal Units.Subtraction(one_meter, 2.inch + 3.foot)
	    (zero_meters - addition).must_equal Units::Subtraction.new(zero_meters, 2.inch + 3.foot)
	end

	it 'must add a Subtraction proxy' do
	    (one_meter + subtraction).must_equal Units::Addition.new(one_meter, subtraction)
	    (zero_meters + subtraction).must_equal (zero_meters + subtraction)
	end

	it 'must subtract a Subtraction proxy' do
	    (one_meter - subtraction).must_equal Units::Subtraction.new(one_meter, Units::Subtraction.new(2.inch, 3.foot))
	end

	it 'must multiply by a proxy object' do
	    (Rational(2).meter * addition).must_equal Units::Addition.new(2.inch * Rational(2).meter, 3.foot * Rational(2).meter)
	    (zero_meters * addition).must_equal Units.Addition(2.inch * zero_meters, 3.foot * zero_meters)
	end

	it 'must divide by a proxy object' do
	    (four_meters / Units::Addition.new(1.inch, 2.foot)).must_equal Units::Division.new(four_meters, Units::Addition.new(1.inch, 2.foot))
	end
    end
end
