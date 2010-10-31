require 'chronic'
require 'test/unit'

class TestRussian < Test::Unit::TestCase
  TIME_2010_09_01_07_00_00 = Time.local(2010, 9, 1, 7, 0, 0)
  def setup
    #Chronic.debug = true
  end
  def teardown
    Chronic.debug = false
  end

  def test_relative_russian_words
    t1 = parse_now "сегодня"
    assert_equal Time.local(2010, 9, 1, 16), t1

    t1 = parse_now "завтра"
    assert_equal Time.local(2010, 9, 2, 12), t1

    t1 = parse_now "послезавтра"
    assert_equal Time.local(2010, 9, 3, 12), t1

    t1 = parse_now "вчера"
    assert_equal Time.local(2010, 8, 31, 12), t1

    t1 = parse_now "позавчера"
    assert_equal Time.local(2010, 8, 30, 12), t1
  end

  def test_russian_week_days
    {"sun" => "воскресенье", "mon" => "понедельник",
     "tue" => "вторник", "wed" => "среда",
     "thu" => "четверг", "fri" => "пятница",
     "sat" => "суббота" }.each do |english, russian|
      assert_equal parse_now(english), parse_now(russian)
    end
    assert_equal parse_now("суббота"), parse_now("сбт")
    # prepositions
    assert_equal parse_now("в среду"), parse_now("среда")
  end

  def test_russian_dates
    { "jan" => "январь", "feb" => "февраль", "mar" => "март",
      "apr" => "апрель", "may" => "май", "jun" => "июнь",
      "jul" => "июль", "aug" => "август", "sep" => "сентябрь",
      "oct" => "октябрь", "nov" => "ноябрь", "dec" => "декабрь" }.each do |english_abbr, russian|
      assert_equal parse_now(english_abbr), parse_now(russian)
    end
    assert_equal Time.local(2011, 03, 16, 12), parse_now("16 марта")
  end

  private
  def parse_now(string, options = {})
    Chronic.parse string, {:now => TIME_2010_09_01_07_00_00 }.merge(options)
  end
end

