require File.dirname(__FILE__) + '/helper.rb'


class TestChainsaw < Test::Unit::TestCase
  
  def test_launch
    agent1 = Chainsaw.launch('http://example.com/some', {:user_agent => 'XXX'}) { |cs|
      cs.user_agent = 'Chainsaw XXX'
      cs.set_next 'http://example.com/'
    }
    
    agent2 = Chainsaw.launch('http://example.com/', {:user_agent => 'Chainsaw XXX'})
    
    assert_instance_of Chainsaw::Browser, agent1
    #assert_equal agent1.to_yaml, agent2.to_yaml
    assert_equal agent1.user_agent, agent2.user_agent
    
  end
  
  def test_launch_more
    assert_nothing_raised do
      Chainsaw {
        set_next 'http://example.com/'
      }
    end

    assert_nothing_raised do
      Chainsaw('http://example.com/')
    end

    assert_nothing_raised do
      Chainsaw.launch('http://example.com/some') {
        set_next 'http://example.com/'
      }
    end
  end



end

