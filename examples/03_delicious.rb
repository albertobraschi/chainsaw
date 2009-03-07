require 'rubygems'
require 'chainsaw'

# post to delicious.com using API
username = ARGV.shift
password = ARGV.shift
url      = ARGV.shift
desc     = ARGV.shift || ''
tags     = ARGV.shift || ''

uri = URI.parse 'https://api.del.icio.us/v1/posts/add'
uri.query = "url=#{URI.escape url}&description=#{URI.escape desc}&tags=#{URI.escape tags}"

Chainsaw(uri).set_auth(username, password).open {
  puts doc.xpath '//result/@code'
}
