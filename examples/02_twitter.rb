require 'rubygems'
require 'chainsaw'

username, password, tweet = ARGV

Chainsaw.launch('https://twitter.com/home').process { |a|
  f = a.doc.css('.signin').first
  f.xpath('id("username_or_email")').first['value'] = username
  f.xpath('id("session[password]")').first['value'] = password
  a.set_next f
}.process { |a|
  f = a.doc.css('#doingForm').first
  f.xpath('id("status")').first.content = tweet || "(o'-')-o fwip fwip"
  a.set_next f
}.process
