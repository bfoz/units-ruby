Units for Ruby
==============

[![Build Status](https://travis-ci.org/bfoz/units-ruby.png)](https://travis-ci.org/bfoz/units-ruby)

An extension to Ruby's Numeric classes that adds support for units of measure.

License
-------

Copyright 2012-2014 Brandon Fosdick <bfoz@bfoz.net> and released under the BSD
license.

Examples
--------

### Creating numbers with units
```ruby
    require 'units'

    three_meters = 3.meters
    two_meters = 2.m
    one_inch = 1.inch
```
### Converting units
```ruby
    3.meters.to_inches          # => 118.1103 inch
    10.inches.to_mm             # => 254.0 millimeter
```

Supported Units
----------------
All of the SI units listed below allow any of the standard
[SI prefixes](http://en.wikipedia.org/wiki/Metric_prefix) to be prepended to the
unit name. Actually, the US Customary units support the SI prefixes too, but
that's not a typical usage.

Note that the names listed here are the symbol names used by the Units gem, and
are derived from the proper names of the units. They don't exactly match the
proper unit names to maintain consistency and to respect Ruby's naming
conventions.

### SI Primary Units
- meter
- gram
- second
- ampere
- kelvin
- candela
- mole

### SI Derived Units
- hertz
- radian
- steradian
- newton
- pascal
- joule
- watt
- coulomb
- volt
- farad
- ohm
- siemens
- weber
- tesla
- henry
- celsius
- lumen
- lux
- gray
- sievert
- katal
- becquerel

### SI Abbreviations
Some combinations of SI units and prefixes are both verbose and commonly used.
Enough so that it makes sense to support their abbreviations. The supported
abbreviations are listed below.

- mm -> millimeter
- cm -> centimeter
- km -> kilometer

### US Customary Units
Head over to the Wikipedia article on [US Customary Units](http://wikipedia.org/wiki/United_States_customary_units)
to learn about all of these bizare units and their namesakes.

#### Area
- acre
- section
- township

#### "International"
- point
- pica
- inch
- foot
- yard
- mile

#### Mass
- grain
- dram
- ounce
- pound
- hundredweight
- long_hundredweight
- short_ton
- long_ton
- pennyweight
- troy_ounce
- troy_pound

#### Nautical
- fathom
- cable
- nautical_mile

#### Survey
- link
- survey_foot
- rod
- chain
- furlong
- statute_mile
- league

#### Temperature
- fahreheight
- rankine

#### Volume
- acre_foot
- minim
- fluid_dram
- teaspoon
- tablespoon
- fluid_ounce
- jigger
- gill
- cup
- pint
- quart
- barell
- hogshead
