require 'rubygems'
require 'nokogiri'
require 'httpclient'
require 'nkf'

require 'chainsaw/ext/httpclient'
require 'chainsaw/ext/nokogiri'

require 'chainsaw/common'
require 'chainsaw/element'

require 'chainsaw/browser'


Nokogiri::XML::Element.module_eval do 
  include Chainsaw::Element
end

module Chainsaw
  VERSION = '0.0.3'
  
  #
  # Return a instance of the Chainsaw::Browser class.
  def self.launch(*args)
    cs = Chainsaw::Browser.new *args
    if block_given?
      block = Proc.new
      cs.instance_eval { process_chain &block }
    end
    cs
  end
end

module Kernel
  #
  # alias for Chainsaw#launch
  def Chainsaw(*args)
    Chainsaw.launch *args
  end
  
  module_function :Chainsaw
end
