require 'rubygems'
require 'chainsaw'

query = ARGV.shift

Chainsaw.launch('http://google.com/').
open { |a|
  f = a.doc.xpath('//form[@name="f"]').first
  q = f.xpath('//input[@name="q"]').first
  q['value'] = query || 'Hello world'
  a.set_next f
}.
submit { |a|
  a.doc.search('//a').each do |l|
    puts l.content
  end
}
