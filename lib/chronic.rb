#=============================================================================
#
#  Name:       Chronic
#  Author:     Tom Preston-Werner
#  Purpose:    Parse natural language dates and times into Time or
#              Chronic::Span objects
#
#=============================================================================

$:.unshift File.dirname(__FILE__)     # For use/testing when no gem is installed

require 'core_ext/object'
require 'core_ext/time'

require 'chronic/chronic'
require 'chronic/handlers'

require 'chronic/repeater'
require 'chronic/repeaters/repeater_year'
require 'chronic/repeaters/repeater_season'
require 'chronic/repeaters/repeater_season_name'
require 'chronic/repeaters/repeater_month'
require 'chronic/repeaters/repeater_month_name'
require 'chronic/repeaters/repeater_fortnight'
require 'chronic/repeaters/repeater_week'
require 'chronic/repeaters/repeater_weekend'
require 'chronic/repeaters/repeater_weekday'
require 'chronic/repeaters/repeater_day'
require 'chronic/repeaters/repeater_day_name'
require 'chronic/repeaters/repeater_day_portion'
require 'chronic/repeaters/repeater_decade'
require 'chronic/repeaters/repeater_hour'
require 'chronic/repeaters/repeater_minute'
require 'chronic/repeaters/repeater_second'
require 'chronic/repeaters/repeater_time'

require 'chronic/grabber'
require 'chronic/pointer'
require 'chronic/scalar'
require 'chronic/ordinal'
require 'chronic/separator'
require 'chronic/time_zone'
require 'chronic/blunt.rb'
require 'chronic/translation.rb'

require 'numerizer/numerizer'

module Chronic
	VERSION = "0.3.0.2"

	class << self
		attr_accessor :debug
		attr_accessor :time_class
	end

	self.debug = false
	self.time_class = Time
end
