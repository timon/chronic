# encoding: utf-8
module Chronic
  register_normalization :ru do |normalized_text|
    # relative to now
    normalized_text.gsub!(/\bсегодня\b/ui, 'this day')
    normalized_text.gsub!(/\bвчера\b/ui, 'last day')
    normalized_text.gsub!(/\bпозавчера\b/ui, '1 day past yesterday')
    normalized_text.gsub!(/\bзавтра\b/ui, 'next day')
    normalized_text.gsub!(/\bпослезавтра\b/ui, '2 days future noon pm')
    # time units
    normalized_text.gsub!(/\bдень|дн(я|ей)\b/ui, 'days')
    normalized_text.gsub!(/\bнедел[ьеюия]\b/ui, 'weeks')
    normalized_text.gsub!(/\bмесяц(|а|ев)\b/ui, 'months')
    normalized_text.gsub!(/\bгода?|лет\b/ui, 'years')
    # week days
    normalized_text.gsub!(/\b(пн|пнд|понедельник[ау]?)\b/ui, 'monday')
    normalized_text.gsub!(/\b(вт|втр|вторник[ау]?)\b/ui, 'tuesday')
    normalized_text.gsub!(/\b(ср|срд|сред[аеу])\b/ui, 'wednesday')
    normalized_text.gsub!(/\b(чт|чтв|четверг[ау]?)\b/ui, 'thursday')
    normalized_text.gsub!(/\b(пт|птн|пятниц[аыу]?)\b/ui, 'friday')
    normalized_text.gsub!(/\b(сб|сбт|субб?от[аые])\b/ui, 'saturday')
    normalized_text.gsub!(/\b(вс|вск|воскресен[ьи][еяю])\b/ui, 'sunday')
    # past and future
    normalized_text.gsub!(/\bпрош(л|едш)([ыиео]й|[ое]му|ую|ого|ая)\b/ui, 'last')
    normalized_text.gsub!(/\b(буду|следу)ю?щ(ий|ую|ем|ей|ая|ee)\b/ui, 'next')
    normalized_text.gsub!(/(.*)\bчерез\s+(\d+)?\s*(\S*)/ui) { "#{$2 || 1} #{$3} after #{$1}"}
    normalized_text.gsub!(/\bсейчас\b/ui, 'this second')
    normalized_text.gsub!(/\bназад\b/ui, 'past')
    normalized_text.gsub!(/\bэт(а|о[ймт]?|им)\b/ui, 'this')
    # months
    normalized_text.gsub!(/\b(\d+)?\s*(янв|январ[ьяюе])\b/ui, 'january \1')
    normalized_text.gsub!(/\b(\d+)?\s*(фев|феврал[ьяюе])\b/ui, 'february \1')
    normalized_text.gsub!(/\b(\d+)?\s*(мар|март[ауе]?)\b/ui, 'march \1')
    normalized_text.gsub!(/\b(\d+)?\s*(апр|апрел[ьяюе])\b/ui, 'april \1')
    normalized_text.gsub!(/\b(\d+)?\s*(ма[йяюе])\b/ui, 'may \1')
    normalized_text.gsub!(/\b(\d+)?\s*(июн[ьяюе])\b/ui, 'june \1')
    normalized_text.gsub!(/\b(\d+)?\s*(июл[ьяюе])\b/ui, 'july \1')
    normalized_text.gsub!(/\b(\d+)?\s*(авг|август[уае]?)\b/ui, 'august \1')
    normalized_text.gsub!(/\b(\d+)?\s*(сен|сентябр[ьяюе])\b/ui, 'september \1')
    normalized_text.gsub!(/\b(\d+)?\s*(окт|октябр[ьяюе])\b/ui, 'october \1')
    normalized_text.gsub!(/\b(\d+)?\s*(ноя|ноябр[ьяюе])\b/ui, 'november \1')
    normalized_text.gsub!(/\b(\d+)?\s*(дек|декабр[ьяюе])\b/ui, 'december \1')
    # times of day
    normalized_text.gsub!(/\bутр(о[м]?|а)\b/ui, 'morning')
    normalized_text.gsub!(/\bвечер(о[м]|а)\b/ui, 'evening')
    normalized_text.gsub!(/\bноч(и|ь[ю]?)\b/ui, 'night')
    normalized_text.gsub!(/\bполдень\b/ui, '12:00pm')
    normalized_text.gsub!(/\bполночь\b/ui, '12:00am')
    # afternoon is not translated due to possible ambiguation in russian
    # version
  end
end

