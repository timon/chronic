# English idioms translation
#
module Chronic
  register_normalization :en do |normalized_text|
    normalized_text.gsub!(/\btoday\b/i, 'this day')
    normalized_text.gsub!(/\btomm?orr?ow\b/i, 'next day')
    normalized_text.gsub!(/\byesterday\b/i, 'last day')
    normalized_text.gsub!(/\bnoon\b/i, '12:00')
    normalized_text.gsub!(/\bmidnight\b/i, '24:00')
    normalized_text.gsub!(/\bbefore now\b/i, 'past')
    normalized_text.gsub!(/\bnow\b/i, 'this second')
    normalized_text.gsub!(/\b(ago|before)\b/i, 'past')
    normalized_text.gsub!(/\bthis past\b/i, 'last')
    normalized_text.gsub!(/\bthis last\b/i, 'last')
    normalized_text.gsub!(/\b(?:in|during) the (morning)\b/i, '\1')
    normalized_text.gsub!(/\b(?:in the|during the|at) (afternoon|evening|night)\b/i, '\1')
    normalized_text.gsub!(/\btonight\b/i, 'this night')
    normalized_text.gsub!(/\b\d+:?\d*[ap]\b/i,'\0m')
    normalized_text.gsub!(/(\d)([ap]m|oclock)\b/i, '\1 \2')
    normalized_text.gsub!(/\b(hence|after|since|from)\b/i, 'future')
    normalized_text.gsub!(/\bh[ou]{0,2}rs?\b/i, 'hour')
  end
end

