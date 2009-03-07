

module Chainsaw
  
  class Browser
    include Chainsaw::Util
    
    DEFAULT_USER_AGENT = "Chainsaw/#{VERSION}"
    
    attr_accessor :user_agent, :ignore_redirect, :hide_referer, :max_history_count, :encoding  # configurables
    attr_accessor :request_headers, :url_base, :results
    attr_reader :engine, :response, :history, :request_count      # session
    
    def initialize(location = '', options = {})
      @user_agent        = options[:user_agent] || DEFAULT_USER_AGENT
      @max_history_count = options[:max_history_count] || 20
      @ignore_redirect   = options[:ignore_redirect] || false
      @hide_referer      = options[:hide_referer] || false
      @encoding          = options[:encoding]
      @url_base          = options[:url_base] || ''
      @request_headers   = options[:request_headers] || {}
      
      @history = []
      @results = []
      
      @request_count = 0
      
      @engine = HTTPClient.new
      
      set_next(location)
      self
    end
    
    def add_header(key, value, overwrite_if_exists = true)
      @request_headers = {} if @request_header.nil?
      if !@request_headers.has_key?(key) or overwrite_if_exists
        @request_headers[key] = value
      end
      self
    end
    
    def set_next(obj)
      @reserved = obj
      self
    end
    
    def set_auth(username, password)
      @engine.set_auth(@reserved.to_s, username, password)
      self
    end
    
    def process(&block)
      if @reserved.is_a?(Nokogiri::XML::Element) and @reserved.is_form?
        begin
          submit &block
        rescue TypeError
          open &block
        end
      else
        open &block
      end
    end
    
    alias > process
    
    def open
      uri = prepare_next
      @response = request(:get, uri)
      process_chain &Proc.new if block_given?
      self
    end
    
    def submit
      submit_with(nil)
      process_chain &Proc.new if block_given?
      self
    end
    
    def submit_with(button_name, image_x = -1, image_y = -1)
      uri, form = prepare_next
      raise TypeError, 'No form found.' unless form
      unless button_name
        s = form.xpath('.//input[@type="submit"]')
        button_name = s.first['name'] if s.length
      end
      query = form.serialize_form(button_name, image_x, image_y)
      method = (form['method'] || 'get').downcase
      if method == 'get'
        @response = request(:get, uri, query)
      elsif method == 'post'
        paths, q = query.partition do |name, value|
          value.instance_of? Pathname
        end
        files = []
        begin
          paths.each do |name, path| 
            f = File.open(path, 'rb')
            q.push [name, f]
            files.push f
          end
          @response = request(:post, uri, q) 
        ensure
          files.each { |f| f.close unless f.nil? }
        end
      end
      process_chain &Proc.new if block_given?
      self
    end
    
    def back
      require 'ostruct'
      cleanup
      @history.shift
      back = @history.first
      return self if back.nil?
      @response = OpenStruct.new(
        'uri' => back[:location],
        'contenttype' => back[:content_type],
        'content' => back[:document]
      )
      @reserved = nil
      process_chain &Proc.new if block_given?
      self
    end
    
    def uri
      return nil if @response.nil?
      @response.uri
    end
    
    def each(&block)
      iterate(false, &block)
    end
    
    def each_with_index(&block)
      iterate(true, &block)
    end
    
    def document
      return @document unless @document.nil?
      return nil if res.content.nil?
      return nil unless is_xml_parsable?(res.contenttype)
      enc = @encoding || Encoding.guess(res.content)
      @document = Nokogiri.parse(res.content, nil, enc)
      
      b = @document.xpath('//base')
      base = b.empty? ? '' : b[0]['href']
      @history.first.update(:base => base.to_s)
      
      @document
    end
    
    def file
      return @file unless @file.nil?
      return nil if @response.content.nil?
      
      Tempfile.open(uri.to_s.split('/').last) do |f|
        f.binmode.write @response.content
        @file = f
      end
      
      @file
    end
    
    alias res response
    alias doc document
    
  private
    
    def process_chain(&block)
      unless block.arity == -1
        results.push yield(self)
      else
        instance_exec(eval('self', block)) do |caller_self|
          mm = lambda do |name, *args|
            caller_self.__send__(name, *args)
          end
          self.class.__send__(:define_method, :method_missing, &mm)
        end
        results.push instance_eval &block
        self.class.__send__(:undef_method, :method_missing)
      end
    end
    
    def request(method, uri, query = nil)
      raise TypeError, "Invalid URI: #{qq uri.to_s}" unless uri.kind_of?(URI::HTTP)
      
      call = method.to_s || 'get'
      call += '_r' unless @ignore_redirect
      add_header('Referer', @history.first[:location], false) if !@hide_referer and @history.first
      @request_count += 1
      r = begin
        @engine.send(call, uri, query, @request_headers)
      rescue HTTPClient::BadResponseError => e
        e.res
      rescue
        raise(
          Chainsaw::RequestError, 
          "Error occured during #{to_nth(@request_count)} request; url: #{qq uri.to_s}"
        )
      end
      
      # history
      set_history uri.to_s, r.contenttype, r.content
      r
    end
    
    def iterate(with_index, &block)
      set = prepare_next
      unless set
        warn 'Iteration called without Enumerable.'
        return self 
      end
      
      set.each_with_index do |e, index|
        set_next(e)
        with_index ? yield(self, index) : yield(self)
        back
      end
      self
    end
    
    def prepare_next(reserved = nil)
      reserved ||= @reserved
      cleanup
      case reserved
      when String   # expecting a url
        return prepare_next(URI.parse reserved)
      when URI
        if reserved.is_a?(URI::HTTP)
          return reserved
        elsif @history.size > 0
          base = @history[0][:base] || ''
          base = @history[0][:location] if base.empty?
          l = URI.join base, reserved
          return prepare_next(l) if l.is_a?(URI::HTTP)
        end
      when Nokogiri::XML::Element
        url = reserved['href'] || reserved['action'] || reserved['value']
        if reserved.is_form?
          return [prepare_next(url), reserved]
        else
          return prepare_next(url)
        end
      when Enumerable
        return reserved
      end
      
      raise TypeError, "Unexpected value is set for next before #{to_nth(@request_count+1)} request: #{@reserved.class.name}"
    end
    
    def cleanup
      @reserved = @document = @response = @file = nil
    end
    
    def set_history(location, content_type, document, base = nil)
      document = nil unless is_xml_parsable?(content_type)
      data = {
        :location => location, 
        :content_type => content_type,
        :document => document, 
        :base => base
      }
      @history.unshift(data)
      @history.slice! @max_history_count, @history.size - @max_history_count
    end
    
    
    
  end
end
