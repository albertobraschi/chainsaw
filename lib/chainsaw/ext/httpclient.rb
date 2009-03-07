

class HTTPClient
  def get_r(uri, query = nil, extheader = {}, &block)
    follow_redirect(:get, uri, query, nil, extheader, &block)
  end
  
  def post_r(uri, body = nil, extheader = {}, &block)
    follow_redirect(:post, uri, nil, body, extheader, &block)
  end
  
  alias do_get_header_original do_get_header
  def do_get_header(req, res, sess)
    # It is not a good way, but HTTPClient cannot keep requested URIs..
    unless res.respond_to?(:uri)
      HTTP::Message.module_eval do
        attr_accessor :uri
      end
    end
    res.uri = req.header.request_uri
    do_get_header_original(req, res, sess)
  end
end



