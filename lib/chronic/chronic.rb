module Chronic
	class << self

		# Parses a string containing a natural language date or time. If the parser
		# can find a date or time, either a Time or Chronic::Span will be returned
		# (depending on the value of <tt>:guess</tt>). If no date or time can be found,
		# +nil+ will be returned.
		#
		# Options are:
		#
		# [<tt>:context</tt>]
		#     <tt>:past</tt> or <tt>:future</tt> (defaults to <tt>:future</tt>)
		#
		#     If your string represents a birthday, you can set <tt>:context</tt> to <tt>:past</tt>
		#     and if an ambiguous string is given, it will assume it is in the
		#     past. Specify <tt>:future</tt> or omit to set a future context.
		#
		# [<tt>:now</tt>]
		#     Time (defaults to Time.now)
		#
		#     By setting <tt>:now</tt> to a Time, all computations will be based off
		#     of that time instead of Time.now. If set to nil, Chronic will use Time.now.
		#
		# [<tt>:guess</tt>]
		#     +true+, +false+, +"start"+, +"middle"+, and +"end"+ (defaults to +true+)
		#
		#     By default, the parser will guess a single point in time for the
		#     given date or time.  +:guess+ => +true+ or +"middle"+ will return the middle
		#     value of the range.  If +"start"+ is specified, Chronic::Span will return the
		#     beginning of the range.  If +"end"+ is specified, the last value in
		#     Chronic::Span will be returned. If you'd rather have the entire time span returned,
		#     set <tt>:guess</tt> to +false+ and a Chronic::Span will be returned.
		#
		# [<tt>:ambiguous_time_range</tt>]
		#     Integer or <tt>:none</tt> (defaults to <tt>6</tt> (6am-6pm))
		#
		#     If an Integer is given, ambiguous times (like 5:00) will be
		#     assumed to be within the range of that time in the AM to that time
		#     in the PM. For example, if you set it to <tt>7</tt>, then the parser will
		#     look for the time between 7am and 7pm. In the case of 5:00, it would
		#     assume that means 5:00pm. If <tt>:none</tt> is given, no assumption
		#     will be made, and the first matching instance of that time will
		#     be used.
		def parse(text, specified_options = {})
			# strip any non-tagged tokens
			@tokens = tokenize(text, specified_options).select { |token| token.tagged? }

			if Chronic.debug
				puts "+---------------------------------------------------"
				puts "| " + @tokens.to_s
				puts "+---------------------------------------------------"
			end

			options = default_options(specified_options)

			# do the heavy lifting
			begin
				span = self.tokens_to_span(@tokens, options)
			rescue
				raise
				return nil
			end

			# guess a time within a span if required
			if options[:guess]
				return self.guess(span, options[:guess])
			else
				return span
			end
		end

		def strip_tokens(text, specified_options = {})
			# strip any tagged tokens
			return tokenize(text, specified_options).select { |token| !token.tagged? }.map { |token| token.word }.join(' ')
		end

		# Returns an array with text tokenized by the respective classes
		def tokenize(text, specified_options = {})
			@text = text

			options = default_options(specified_options)
			# store now for later =)
			@now = options[:now]

			# put the text into a normal format to ease scanning
			puts "+++ text = #{text}" if Chronic.debug
			text = self.pre_normalize(text, options[:languages])
			puts "--- text = #{text}" if Chronic.debug

			# get base tokens for each word
			@tokens = self.base_tokenize(text)
			puts @tokens if Chronic.debug

			# scan the tokens with each token scanner
			[Repeater].each do |tokenizer|
				@tokens = tokenizer.scan(@tokens, options)
			end

			[Grabber, Pointer, Scalar, Ordinal, Separator, TimeZone].each do |tokenizer|
				@tokens = tokenizer.scan(@tokens)
			end

			return @tokens
		end

		def default_options(specified_options)
			# get options and set defaults if necessary
			default_options = {:context => :future,
				:now => Chronic.time_class.now,
				:guess => true,
				:guess_how => :middle,
				:ambiguous_time_range => 6,
				:endian_precedence => nil}
			options = default_options.merge specified_options

			# handle options that were set to nil
			options[:context] = :future unless options[:context]
			options[:now] = Chronic.time_class.now unless options[:context]
			options[:ambiguous_time_range] = 6 unless options[:ambiguous_time_range]

			# ensure the specified options are valid
			specified_options.keys.each do |key|
				default_options.keys.include?(key) || raise(InvalidArgumentException, "#{key} is not a valid option key.")
			end
			[:past, :future, :none].include?(options[:context]) || raise(InvalidArgumentException, "Invalid value ':#{options[:context]}' for :context specified. Valid values are :past and :future.")
			["start", "middle", "end", true, false].include?(options[:guess]) || validate_percentness_of(options[:guess]) || raise(InvalidArgumentException, "Invalid value ':#{options[:guess]}' for :guess how specified. Valid values are true, false, \"start\", \"middle\", and \"end\".  true will default to \"middle\". :guess can also be a percent(0.60)")

			return options
		end

		# Clean up the specified input text by stripping unwanted characters,
		# converting idioms to their canonical form, converting number words
		# to numbers (three => 3), and converting ordinal words to numeric
		# ordinals (third => 3rd)
		def pre_normalize(text, languages = nil) #:nodoc:
			normalized_text = text.to_s
			normalized_text = numericize_numbers(normalized_text)
			normalized_text.gsub!(/['",]/, '')
			normalized_text.gsub!(/(\d+\:\d+)\.(\d+)/, '\1\2')
			normalized_text.gsub!(/ \-(\d{4})\b/, ' tzminus\1')
			normalized_text.gsub!(/([\/\-\,\@])/) { ' ' + $1 + ' ' }
      translate!(normalized_text, languages)
			#not needed - see test_parse_before_now (test_parsing.rb +726)
			#normalized_text.gsub!(/\bbefore now\b/, 'past')

			normalized_text = numericize_ordinals(normalized_text)
		end

		# Convert number words to numbers (three => 3)
		def numericize_numbers(text) #:nodoc:
			Numerizer.numerize(text)
		end

		# Convert ordinal words to numeric ordinals (third => 3rd)
		def numericize_ordinals(text) #:nodoc:
			text
		end

		# Split the text on spaces and convert each word into
		# a Token
		def base_tokenize(text) #:nodoc:
			text.split(' ').map { |word| Token.new(word) }
		end

		# Guess a specific time within the given span
		def guess(span, guess=true) #:nodoc:
			return nil if span.nil?
			if span.width > 1
				# Account for a timezone difference between the start and end of the range.
				# This most likely will happen when dealing with a Daylight Saving Time start
				# or end day.
				gmt_offset_diff = span.begin.gmt_offset - span.end.gmt_offset
				case guess
				when "start"
					span.begin
				when true, "middle"
					span.begin + ((span.width - gmt_offset_diff) / 2)
				when "end"
					span.begin + (span.width - gmt_offset_diff)
				else
					span.begin + ((span.width - gmt_offset_diff) * guess)
				end
			else
				span.begin
			end
		end

		# Validates numericality of something
		def validate_percentness_of(number) #:nodoc:
			number.to_s.to_f == number && number >= 0 && number <= 1
		end
	end

	class Token #:nodoc:
		attr_accessor :word, :tags

		def initialize(word)
			@word = word
			@tags = []
		end

		# Tag this token with the specified tag
		def tag(new_tag)
			@tags << new_tag
		end

		# Remove all tags of the given class
		def untag(tag_class)
			@tags = @tags.select { |m| !m.kind_of? tag_class }
		end

		# Return true if this token has any tags
		def tagged?
			@tags.size > 0
		end

		# Return the Tag that matches the given class
		def get_tag(tag_class)
			matches = @tags.select { |m| m.kind_of? tag_class }
			#matches.size < 2 || raise("Multiple identical tags found")
			return matches.first
		end

		# Print this Token in a pretty way
		def to_s
			"#{@word}(#{@tags.join(', ')})"
		end
	end

	# A Span represents a range of time. Since this class extends
	# Range, you can use #begin and #end to get the beginning and
	# ending times of the span (they will be of class Time)
	class Span < Range

		def initialize(range_begin, range_end)
			# Use exclusive range.
			super(range_begin, range_end, true)
		end

		# Returns the width of this span in seconds
		def width
			(self.end - self.begin).to_i
		end

		# Add a number of seconds to this span, returning the
		# resulting Span
		def +(seconds)
			Span.new(self.begin + seconds, self.end + seconds)
		end

		# Subtract a number of seconds to this span, returning the
		# resulting Span
		def -(seconds)
			self + -seconds
		end

		# Prints this span in a nice fashion
		def to_s
			'(' << self.begin.to_s << '...' << self.end.to_s << ')'
		end
	end

	# Tokens are tagged with subclassed instances of this class when
	# they match specific criteria
	class Tag #:nodoc:
		attr_accessor :type

		def initialize(type)
			@type = type
		end

		def start=(s)
			@now = s
		end
	end

	# Internal exception
	class ChronicPain < Exception #:nodoc:

	end

	# This exception is raised if an invalid argument is provided to
	# any of Chronic's methods
	class InvalidArgumentException < Exception

	end
end
