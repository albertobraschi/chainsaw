require 'webrick'

TEST_SERVER_CONFIG = {
  :DocumentRoot => File.join(File.expand_path(File.dirname(__FILE__)), 'htdocs'),
  :BindAddress => '127.0.0.1',
  :Port => 3080,
  :CGIInterpreter => WEBrick::HTTPServlet::CGIHandler::Ruby,
}

if __FILE__ == $0
  s = WEBrick::HTTPServer.new(TEST_SERVER_CONFIG)
  s.mount(
    '/cgi.rb', 
    WEBrick::HTTPServlet::CGIHandler, 
    TEST_SERVER_CONFIG[:DocumentRoot] + '/cgi.rb'
  )
  Signal.trap(:INT) { s.shutdown }
  Signal.trap(:TERM) { exit 0 }
  s.start
end
