require 'cgi'
require 'yaml'
require 'base64'

cgi = CGI.new
env = Hash[ENV.collect() { |k, v| [k, v] }]
res = {}

if cgi.has_key? 'redirect'
  l = env['REQUEST_URI'].split('cgi.rb').first + '02.html'
  cgi.print [
    'Status: 302 Moved Temporarily',
    'Location: ' + l,
    "\n"
  ].join("\n")
  exit 0
end

if cgi.has_key? 'auth'
  auth = env['HTTP_AUTHORIZATION'] || ''
  user_pass = Base64.decode64(auth.split.last || '').split(/:/, 2)
  if user_pass.empty?
    cgi.print [
      'Status: 401 Unauthorized',
      'WWW-Authenticate: Basic realm="test"',
      "\n", 
      'Access denied.'
    ].join("\n")
    exit 0
  else
    res['auth'] = user_pass.join(':')
  end
end

if cgi.keys.find {|k| k =~ /^(\d{3})$/}
  status = $1
  cgi.print [
    "Status: #{status}", 
    "\n", 
    "Status #{status}"
  ].join("\n")
  exit 0
end

if env['CONTENT_TYPE'] =~ %r{^multipart/form-data;}
  upload = cgi.params['f'][0]
  res['upload'] = {
    'size' => upload.size,
    'original_filename' => upload.original_filename,
    'content_type' => upload.content_type
  } if upload
end

res.update(
  'params' => cgi.params,
  'cookies' => cgi.cookies,
  'env' => env
)

cgi.print "\n\n" + res.to_yaml
