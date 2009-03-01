require File.dirname(__FILE__) + '/helper.rb'

class TestExt < Test::Unit::TestCase

  def setup ; end
  
  def test_httpclient_get_r
    h = HTTPClient.new 
    d = h.get_r(URI.join(TEST_URL, '01.html'), nil, {}) #TODO: test with redirect
    assert_equal 200, d.status
  end
  
  def test_nokogiri_id_func
    x = <<-XML
    <doc>
      <items>
        <item id="item1" name="abc"/>
        <item id="item2" name="efd"/>
      </items>
    </doc>
    XML
    n = Nokogiri::XML.parse(x)
    ps = n.fix_xpath('id("a")', 'id("b")/x', '//*[id="c"]')
    assert_equal ['.//*[@id="a"]', './/*[@id="b"]/x', '//*[id="c"]'], ps
    
    i = n.search('id("item1")')[0]
    assert_equal 'abc', i.get_attribute('name')
  end
  
  
end