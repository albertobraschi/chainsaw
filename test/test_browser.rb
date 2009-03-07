require File.dirname(__FILE__) + '/helper.rb'


class TestBrowser < Test::Unit::TestCase

  def setup
    @text_val = 'value for text field'
  end
  
  
  def test_open
    cs = Chainsaw.launch(TEST_URL + '01.html')
    cs.open { |cs|
      assert_equal cs.uri.to_s, TEST_URL + '01.html'
      assert_instance_of Nokogiri::HTML::Document, cs.doc
      assert_equal 200, cs.res.status
      assert_equal  'text/html', cs.res.contenttype
      links = cs.doc.search('//a')
      assert_equal links.length, 5
      cs.set_next links[1]
    }
    cs.open { |cs|
      assert_equal cs.uri.to_s, TEST_URL + '02.html'
      assert_instance_of Nokogiri::HTML::Document, cs.doc
      links = cs.doc.search('//a')
      cs.set_next links.last
    }
    cs.open { |cs|
      assert_equal cs.uri.to_s, TEST_URL + '00.html'
      assert_equal 404, cs.res.status
    }
  end

  def test_back
    d = ''
    cs = Chainsaw.launch(TEST_URL + '01.html').
    open { |cs|
      d = cs.doc.to_s
      cs.set_next cs.doc.search('//a')[1]
    }.open.back { |cs|
      assert_equal TEST_URL + '01.html', cs.uri.to_s
      assert_equal d, cs.doc.to_s
    }
  end
  
  def test_open_file
    Chainsaw.launch(TEST_URL + 'img.gif').
    open { |cs|
      assert_equal 200, cs.res.status
      assert_equal 'image/gif', cs.res.contenttype
      assert_not_nil cs.file
      assert_instance_of Tempfile, cs.file
      
      original = File.stat(File.dirname(__FILE__) + '/htdocs/img.gif')
      saved = File.stat(cs.file.path)
      assert_equal saved.size, original.size
    }
  end
  
  def test_submit_get
    Chainsaw.launch(TEST_URL + '03.html').
    open { |cs|
      assert_instance_of Nokogiri::HTML::Document, cs.doc
      form = cs.doc.search('id("get-form")').first
      form.xpath('//input[@name="t"]').attr('value', @text_val)
      cs.set_next form
    }.
    submit { |cs|
      x = YAML.load cs.res.content
      assert_equal @text_val, x['params']['t'][0]
      assert_equal 'go', x['params']['s'][0]
    }
  end
  
  def test_submit_post
    Chainsaw.launch(TEST_URL + '03.html').
    open { |cs|
      assert_instance_of Nokogiri::HTML::Document, cs.doc
      form = cs.doc.search('id("post-form")').first
      form.xpath('//input[@name="t"]').attr('value', @text_val)
      cs.set_next form
    }.
    submit { |cs|
      x = YAML.load cs.res.content
      assert_equal @text_val, x['params']['t'][0]
      assert_equal 'go', x['params']['s'][0]
    }
  end
  
  
  def test_submit_process
    Chainsaw.launch(TEST_URL + '03.html').
    process { |cs|
      assert_instance_of Nokogiri::HTML::Document, cs.doc
      form = cs.doc.search('id("post-form")').first
      form.xpath('//input[@name="t"]').attr('value', @text_val)
      cs.set_next form
    }.
    process { |cs|
      x = YAML.load cs.res.content
      assert_equal @text_val, x['params']['t'][0]
      assert_equal 'go', x['params']['s'][0]
    }
  end
  
  def test_submit_file
    file_path = File.dirname(__FILE__) + '/htdocs/01.html'
    Chainsaw.launch(TEST_URL + '03.html').
    open { |cs|
      assert_instance_of Nokogiri::HTML::Document, cs.doc
      form = cs.doc.search('id("upload-form")').first
      form.xpath('//input[@name="f"]').attr('value', file_path)
      cs.set_next form
    }.
    submit { |cs|
      stat = File.stat(file_path)
      x = YAML.load cs.res.content
      data = x['upload']
      assert_equal stat.size, data['size'].to_i
    }
  end
  
  def test_each
    count = 0
    Chainsaw.launch(TEST_URL + '01.html').open { |cs|
      cs.set_next cs.doc.xpath('//a')
    }.each { |cs|
      count += 1
      cs.open { |cs|
        if count == 4
          x = YAML.load cs.res.content
          assert_equal TEST_URL + '01.html', x['env']['HTTP_REFERER']
        end
      }
    }
    assert_equal 5, count
  end
  
  def test_each_with_index
    count = 0
    Chainsaw.launch(TEST_URL + '01.html').open { |cs|
      cs.set_next cs.doc.xpath('//a')
    }.each_with_index { |cs, index|
      assert_equal index, count
      count += 1
      cs.open { |cs|
        if count == 4
          x = YAML.load cs.res.content
          assert_equal TEST_URL + '01.html', x['env']['HTTP_REFERER']
        end
      }
    }
  end
  
  def test_referer
    Chainsaw.launch(TEST_URL + '01.html').
    open { |cs|
      cs.set_next cs.doc.search('//a[contains(@href,"cgi.rb")]')[0]
    }.
    open { |cs|
      x = YAML.load cs.res.content
      assert_equal TEST_URL + '01.html', x['env']['HTTP_REFERER']
    }
    
    Chainsaw.launch(TEST_URL + '01.html', {:hide_referer => true}).
    open { |cs|
      cs.set_next cs.doc.search('//a[contains(@href,"cgi.rb")]')[0]
    }.
    open { |cs|
      x = YAML.load cs.res.content
      assert_nil x['env']['HTTP_REFERER']
    }
    
  end
  
=begin
  ## this test works fine but very slow
  def test_auth
    user_pass = 'testuser:testpass'
    Chainsaw.launch(TEST_URL + 'cgi.rb?auth').
    set_auth(*user_pass.split(':')).
    open {|cs|
      x = YAML.load cs.res.content
      assert_equal user_pass, x['auth']
      cs.set_next cs.uri
    }.
    open { |cs|
      assert_equal 200, cs.res.status
      cs.uri
    }
    
    # I want to fix this to return 401 status and content body...
    assert_raise Chainsaw::RequestError do 
      Chainsaw.launch(TEST_URL + 'cgi.rb?auth').
      open { |cs|
        assert_equal 401, cs.res.status
      }
    end
    
    assert_raise Chainsaw::RequestError do 
      Chainsaw.launch.
      set_auth(*user_pass.split(':')).
      set_next(TEST_URL + 'cgi.rb?auth').
      open { |cs|
          assert_equal 401, cs.res.status
      }
    end
  end
=end
  
  def test_redirect
    Chainsaw.launch(TEST_URL + 'cgi.rb?redirect').
    open { |cs|
      assert_equal TEST_URL + '02.html', cs.uri.to_s
    }
  end
  
  def test_request_failed
    x = begin
      Chainsaw.launch(TEST_URL).open.
      set_next('http://localhost/').open
    rescue => e
      e.message
    end
    assert_equal 'Error occured during 2nd request; url: "http://localhost/"', x
  end
  
  def test_invalid_url
    assert_raise(TypeError) { Chainsaw.launch('ppppppppppp').open.doc }
  end
  
  def test_max_history_count
    cs = Chainsaw.launch
    cs.max_history_count = 3
    6.times do |i|
      cs.set_next("#{TEST_URL}0#{i+1}.html").open
    end
    
    assert_equal 3, cs.history.size
    assert_equal TEST_URL + '06.html', cs.history.first[:location]
  end
  
  def test_ignore_redirect
    # TODO
  end
  
  def test_result
    cs = Chainsaw.launch
    6.times do |i|
      cs.set_next("#{TEST_URL}0#{i+1}.html").open do |cs|
        [i, cs.uri]
      end
    end
    assert_equal 6, cs.results.size
    assert_equal 2, cs.results[2][0]
    assert_equal TEST_URL + '03.html', cs.results[2][1].to_s
    
  end
  
  def test_bad_response
    assert_nothing_raised do 
      Chainsaw.launch(TEST_URL + 'cgi.rb?500').open { |cs|
        assert_equal 500, cs.res.status
        assert_equal 'Status 500', cs.res.content
      }
    end
  end
  
  def test_aliases
    Chainsaw.launch(TEST_URL + '03.html').> { |cs|
      assert_instance_of Nokogiri::HTML::Document, cs.doc
      form = cs.doc.search('id("post-form")').first
      form.xpath('//input[@name="t"]').attr('value', @text_val)
      cs.set_next form
    }.> { |cs|
      x = YAML.load cs.res.content
      assert_equal @text_val, x['params']['t'][0]
      assert_equal 'go', x['params']['s'][0]
    }
    
  end
  
  def test_mixed_instance
    cs = Chainsaw.launch(TEST_URL + '01.html').open {
      assert_instance_of Nokogiri::HTML::Document, doc
      assert_equal 200, res.status
      links = doc.search('//a')
      assert_equal links.length, 5
      set_next links[1]
      'result1'
    }.open {
      assert_equal res.uri.to_s, TEST_URL + '02.html'
      'result2'
    }
    assert_equal ['result1', 'result2'], cs.results
  end
  
end

