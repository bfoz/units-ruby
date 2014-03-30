require 'minitest/autorun'
require 'units/addition'

describe Units::Addition do
    subject { Units::Addition.new(3.meters, 4.inches) }

    it 'must have an addition operator that returns a new proxy' do
	(subject + 5).must_equal Units::Addition.new(3.meters, 4.inches, 5)
	(5 + subject).must_equal Units::Addition.new(5, 3.meters, 4.inches)
	(subject + subject).must_equal Units::Addition.new(3.meters, 4.inches, 3.meters, 4.inches)
    end

    it 'must have a subtraction operator that returns a new proxy' do
	(subject - 5).must_equal Units::Subtraction.new(subject, 5)
	(5 - subject).must_equal Units::Subtraction.new(5, subject)
	(subject - subject).must_equal Units::Subtraction.new(subject, subject)
    end

    it 'must have a multiplication operator that returns a new proxy' do
	(subject * 5).must_equal Units::Addition.new(15.meters, 20.inches)
	(5 * subject).must_equal Units::Addition.new(15.meters, 20.inches)
	(subject * subject).must_equal ((3.meters * subject) + (4.inches * subject))
    end

    it 'must have a division operator that returns a new proxy' do
	(Units::Addition.new(15.meters, 20.inches) / 5).must_equal subject
	(5 / subject).must_equal Units::Division.new(5, subject)
	(subject / subject).must_equal Units::Division.new(subject, subject)
    end

    describe 'when operating on a Division operator' do
	let(:division) { Units::Division.new 3.meters, 5.foot }

	it 'must add' do
	    (subject + division).must_equal Units::Addition.new(3.meters, 4.inches, division)
	end

	it 'must subtract' do
	    (subject - division).must_equal Units::Subtraction.new(subject, division)
	end

	it 'must multiply' do
	    (subject * division).must_equal Units::Addition.new(3.meters * division, 4.inches * division)
	end

	it 'must divide' do
	    (subject / division).must_equal Units::Addition.new(3.meters / division, 4.inches / division)
	end
    end

    describe 'when operating on a Subtraction operator' do
	let(:subtraction) { Units::Subtraction.new(3.meters, 4.meters) }

	it 'must add a subtraction' do
	    (subject + subtraction).must_equal Units::Addition.new(3.meters, 4.inches, subtraction)
	end

	it 'must subtract a subtraction' do
	    (subject - subtraction).must_equal Units::Subtraction.new(subject, subtraction)
	end

	it 'must multiply by a subtraction' do
	    (subject * subtraction).must_equal Units::Addition.new(3.meters * subtraction, 4.inches * subtraction)
	end

	it 'must divide by a subtraction' do
	    (subject / subtraction).must_equal Units::Addition.new(3.meters / subtraction, 4.inches / subtraction)
	end
    end

    it 'must convert all operands to a desired unit' do
	subject.to_foot.must_be_close_to 10.1758532.foot
    end

    describe 'when pretending to be a Numeric' do
	it 'must have an unary plus method' do
	    (+subject).must_equal subject
	end

	it 'must have an unary minus method' do
	    (-subject).must_equal Units::Addition.new(-3.meters, -4.inches)
	end

	it 'must have an abs2 method' do
	    subject.abs2.must_equal (subject * subject)
	end
    end
end
