# date range support and parsing of strings calling for a sequence of dates
# (currently only 'nth Tuesday in June [2009]' etc).
#
# My first take -- not stable; a lot of fat to cut out.
#
# Chronic::Blunt.dates(Date.today..Date.today+100, {:day => "Wednesday", :week => 0})
# Chronic::Blunt.range(dates_array,{:csv => ','})
# Chronic::Blunt.parse("second Saturday in April 2010")
#
# Blunt b/c it's err, a blunt instrument :)
#
# ...with the exception of brainopia's Array method (which he very
# kindly wrote while I was troubleshooting a more verbose version
# on #ruby-lang). (github.com/brainopia)
#

require 'rubygems'
require 'active_support'

class Object
	def tap
		yield self; self
	end
end

class Array #all credit to brainopia for this
	def group_by_range
		uniq.sort.inject([]) do |result, it|
			result << [] unless result.last && result.last.last.next == it
			result.tap {|ar| ar.last << it }
		end
	end
end

class Date
	def self.parse_dmy(it)
		Date.parse(it.split(/\D/).delete_if {|i| i.size < 1}.reverse.join('-'))
	end
end

class Chronic::Blunt

	ORDINALS = %w[first second third fourth fifth]

	attr_accessor :result

	def initialize
		@result = []
	end


	def self.compare(dates0,dates1)
		ranges = []
		incongruous = []
		dates0.each {|it|
			incongruous << it unless dates1.include?(it)
		}
		ranges << Chronic::Blunt.range(incongruous)

		incongruous = []
		dates1.each {|it|
			incongruous << it unless dates0.include?(it)
		}
		ranges << Chronic::Blunt.range(incongruous)

		@result = ranges
	end


	def self.dates(passed_range, specified_options={})
		default_options = {:day => false,
			:week => :every,
			:hour => false}
		options = default_options.merge specified_options
		specified_options.keys.each do |key|
			default_options.keys.include?(key) || raise(Chronic::InvalidArgumentException, "#{key} is not a valid option key.")
		end

		if passed_range.class == Array
			ranges = passed_range
		else
			ranges = [passed_range]
		end

		@result = []

		ranges.each do |range|
			first = get_date(range.first)-1
			last = get_date(range.last)
			@result << (first += 1) while first < last
		end
		if options[:day]
			find_dates(@result,options[:day].to_s,options[:hour],options[:week])
			@result
		end
		@result
	end

	def self.parse(input)
		string = input.dup.downcase.gsub(/\s{1,}/,' ')
		if (string =~ /first|second|third|fourth|last|every/) == 0
			query = string.gsub(/in/){}.downcase.split(/\s+/)

			if query[0] == 'last'
				week = -1
			elsif query[0] == 'every'
				week = :every
			else
				week = ORDINALS.index(query.first)
			end
			day = query[1].titleize
			month = Date.parse("#{query[3]}/#{query[2]}")
			dates = self.dates(month..month.end_of_month, {:day => day, :week => week})
			if dates.size < 2
				@result = dates.first
			else
				@result = date
			end
		elsif (string =~ /[0-9]{1,2}\s/) == 0 #&& (string =~ /am|pm|hr|/) > 3
			@result = Chronic.parse(Date.parse(string).strftime("%Y-%m-%d"))
		else
			@result = Chronic.parse(string)
		end
		if @result.nil?
			Chronic.parse(Date.parse(string).strftime("%Y-%m-%d"))
		else
			@result
		end
	end



	def self.range(dates, specified_options={})
		default_options = {:csv => false,
			:start_hrs => 0,
			:end_hrs => 0,
			:time => false,
			:day => false,
			:period => false}
		options = default_options.merge specified_options

		specified_options.keys.each do |key|
			default_options.keys.include?(key) || raise(Chronic::InvalidArgumentException, "#{key} is not a valid option key.")
		end

		ranges = dates.flatten.map! {|it| get_date it}.group_by_range.map! do |it|
			if options[:time]
				Time.parse(it.first.strftime("%Y-%m-%d")).advance(:hours => options[:start_hrs])..Time.parse(it.last.strftime("%Y-%m-%d")).advance(:hours => options[:end_hrs])
			else
				it.first..it.last
			end
		end

		if options[:csv]
			if options[:csv] == true
				@result = to_csv(ranges,'|')
			else
				@result = to_csv(ranges,options[:csv].to_s)
			end
		else
			@result = ranges
		end

		if options[:day]
			start_dates = Chronic::Blunt.dates(@result, :day => options[:day])
			periods =[]
			start_dates.each do |it|
				first = it.to_time.advance(:hours => options[:start_hrs])
				last = it.to_time.advance(:days => options[:period], :hours => options[:end_hrs])
				available = false
				ranges.each {|it| available = true if it.include?(first..last)}
				periods << (first..last) if available
			end
			@result = periods
		end
		return @result
	end

	private

	def self.to_csv(ranges,delimiter)
		d = delimiter
		csv = []
		ranges.each {|range| csv << "#{range.first}#{d}#{range.last}"}
		csv
	end


	def self.find_dates(dates,query,hour,week)
		if query.size == 1
			day = query.to_i
		else
			day = Date::DAYNAMES.index(query)
		end
		results = []
		dates.each{|d|
			if hour
				results << (d.to_time + hour.hours) if d.wday == day
			else
				results << d if d.wday == day
			end
		}
		if week != :every
			months = []
			results.each {|day| months << Date.parse("#{day.year}/#{day.mon}")}
			months.uniq!
			months.sort!
			month_days = []
			months.each do |month|
				days = []
				results.each {|day| days << day if day.mon == month.mon}
				if hour
					month_days << days.slice(week).to_time + hour.hours
				else
					month_days << days.slice(week)
				end
			end
			@result = month_days
		else
			@result = results
		end
	end

	def self.get_date(it)
		case it.class.to_s
		when "Date"
			date = it
		when "Time"
			date = Date.parse(it.strftime("%Y-%m-%d"))
		else
			date = Date.parse(Chronic.parse(it).strftime("%Y-%m-%d"))
		end
	end
end
