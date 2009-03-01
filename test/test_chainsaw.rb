require File.dirname(__FILE__) + '/helper.rb'


class TestChainsaw < Test::Unit::TestCase
  
  def test_launch
    agent1 = Chainsaw.launch('http://example.com/some', {:user_agent => 'XXX'}) { |cs|
      cs.user_agent = 'Chainsaw XXX'
      cs.set_next 'http://example.com/'
    }
    
    agent2 = Chainsaw.launch('http://example.com/', {:user_agent => 'Chainsaw XXX'})
    
    assert_instance_of Chainsaw::Browser, agent1
    assert_equal agent1.to_yaml, agent2.to_yaml
    
  end

end

