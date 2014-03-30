require 'minitest/autorun'
require 'units/division'

describe Units::Division do
    subject { Units::Division.new(3.meters, 4.inches) }

    it 'must have an addition operator that returns a new proxy' do
	(subject + 5).must_equal Units::Addition.new(subject, 5)
	(5 + subject).must_equal Units::Addition.new(5, subject)
    end

    it 'must have a subtraction operator that returns a new proxy' do
	(subject - 5).must_equal Units::Subtraction.new(subject, 5)
	(5 - subject).must_equal Units::Subtraction.new(5, subject)
    end

    it 'must have a multiplication operator that returns a new proxy' do
	(subject * 5).must_equal Units::Division.new(15.meters, 4.inches)
	(5 * subject).must_equal Units::Division.new(15.meters, 4.inches)
    end

    it 'must have a division operator that returns a new proxy' do
	(subject / 5).must_equal Units::Division.new(3.meters, 4.inches, 5)
	(5 / subject).must_equal Units::Division.new(5, subject)
    end

    it 'must convert all operands to a desired unit' do
	subject.to_foot.must_be_close_to (3.meters.foot / 4.inches.foot)
    end
end
