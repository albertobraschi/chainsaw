require File.dirname(__FILE__) + '/helper.rb'

class TestM17N < Test::Unit::TestCase

  def setup ; end
  
  def test_guess
    assert_equal 'UTF-8', Chainsaw::Encoding.guess(open(TEST_URL + '04.html').read)
    assert_equal 'SHIFT-JIS', Chainsaw::Encoding.guess(open(TEST_URL + '05.html').read)
    assert_equal 'EUC-JP', Chainsaw::Encoding.guess(open(TEST_URL + '06.html').read)
  end
  
  def test_guess_through_chainsaw
    %w{04.html 05.html 06.html}.each do |html|
      Chainsaw.launch(TEST_URL + html).open { |cs|
        a = cs.doc.xpath('//a[@name="ウェブ検索のサービス"]')
        assert_kind_of Nokogiri::XML::NodeSet, a, "Error during the process #{html}"
        assert_equal 'グーグル・ジャパン', a[0].content, "Error during the process #{html}"
        assert_equal 'ヤフー・ジャパン', a[1].content, "Error during the process #{html}"
      }
    end
  end
end