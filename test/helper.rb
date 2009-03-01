require 'stringio'
require 'test/unit'
require 'chainsaw'
require 'open-uri'
require File.dirname(__FILE__) + '/server.rb'

unless defined? TEST_URL
  TEST_URL = "http://#{TEST_SERVER_CONFIG[:BindAddress]}:#{TEST_SERVER_CONFIG[:Port]}/"

  begin
    open TEST_URL
  rescue
    raise 'Run test/server.rb before you test.'
  end
end
