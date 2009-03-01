require File.dirname(__FILE__) + '/helper.rb'

class TestElement < Test::Unit::TestCase

  def setup ; end
  
  def test_serialize_form_01
    f = <<-FORM
    <form action="">
      <input type="text" name="t1" value="abc" />
      <input type="hidden" name="t2" value="def" />
      <input type="password" name="t3" value="ghi" />
    </form>
    FORM
    n = Nokogiri::HTML.parse f
    n.xpath('.//input[@type="password"]').first.set_attribute('value', 'jkl')
    s = n.xpath('.//form').first.serialize_form
    assert_equal s, [["t1", "abc"], ["t2", "def"], ["t3", "jkl"]]
  end
  
  def test_serialize_form_02
    f = <<-FORM
    <form action="">
      <input name="t1" value="abc" />
      <input type="text" value="def" />
    </form>
    FORM
    n = Nokogiri::HTML.parse f
    s = n.xpath('.//form').first.serialize_form
    assert_equal s, [["t1", "abc"]]
  end
end
