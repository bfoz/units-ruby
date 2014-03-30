require 'minitest/autorun'
require 'units/division'

describe Units::Division do
    subject { Units::Division.new(3.meters, 4.inches) }

    it 'must have an addition operator that returns a new proxy' do
	(subject + 5).must_equal Units::Addition.new(subject, 5)
	(5 + subject).must_equal Units::Addition.new(5, subject)
	(subject + subject).must_equal Units::Addition.new(subject, subject)
    end

    it 'must have a subtraction operator that returns a new proxy' do
	(subject - 5).must_equal Units::Subtraction.new(subject, 5)
	(5 - subject).must_equal Units::Subtraction.new(5, subject)
	(subject - subject).must_equal Units::Subtraction.new(subject, subject)
    end

    it 'must have a multiplication operator that returns a new proxy' do
	(subject * 5).must_equal Units::Division.new(15.meters, 4.inches)
	(5 * subject).must_equal Units::Division.new(15.meters, 4.inches)
	(subject * Units::Division.new(4.meters, 5.inches)).must_equal Units::Division.new(12.meters(2), 20.inches(2))
    end

    it 'must have a division operator that returns a new proxy' do
	(subject / 5).must_equal Units::Division.new(3.meters, 4.inches, 5)
	(5 / subject).must_equal Units::Division.new(5, subject)
	(subject / subject).must_equal Units::Division.new(subject, subject)
    end

    describe 'when operating on an Addition operator' do
	let(:addition) { Units::Addition.new 3.meters, 5.foot }

	it 'must add' do
	    (subject + addition).must_equal Units::Addition.new(subject, addition)
	end

	it 'must subtract' do
	    (subject - addition).must_equal Units::Subtraction.new(subject, addition)
	end

	it 'must multiply' do
	    (subject * addition).must_equal Units::Addition.new(3.meters * subject, 5.foot * subject)
	end

	it 'must divide' do
	    (subject / addition).must_equal Units::Division.new(3.meters, 4.inches, addition)
	end
    end

    describe 'when operating on a Subtraction operator' do
	let(:subtraction) { Units::Subtraction.new(3.meters, 4.meters) }

	it 'must add a subtraction' do
	    (subject + subtraction).must_equal Units::Addition.new(subject, subtraction)
	end

	it 'must subtract a subtraction' do
	    (subject - subtraction).must_equal Units::Subtraction.new(subject, subtraction)
	end

	it 'must multiply' do
	    (subject * subtraction).must_equal Units::Subtraction.new(3.meters * subject, 4.meters * subject)
	end

	it 'must divide' do
	    (subject / subtraction).must_equal Units::Division.new(3.meters, 4.inches, subtraction)
	end
    end

    it 'must convert all operands to a desired unit' do
	subject.to_foot.must_be_close_to (3.meters.foot / 4.inches.foot)
    end

    describe 'when pretending to be a Numeric' do
	it 'must have an unary plus method' do
	    (+subject).must_equal subject
	end

	it 'must have an unary minus method' do
	    (-subject).must_equal Units::Division.new(-3.meters, 4.inches)
	end

	it 'must have an abs2 method' do
	    subject.abs2.must_equal (subject * subject)
	end
    end
end
