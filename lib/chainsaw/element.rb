
require 'pathname'

module Chainsaw
  module Element
    include Chainsaw::Util
    
    def is_form?
      name =~ /^form$/i
    end
    
    def serialize_form(clicked_button = nil, image_x = -1, image_y = -1)
      return nil unless is_form?
      form = []
      if clicked_button.nil?
        s = self.xpath('.//input[@type="submit"]')
        unless s.empty?
          form.push [s.first['name'], s.first['value']]
        end
      else 
        s = self.xpath(".//input[@name=#{qq clicked_button}]")
        
        if s.size and ['submit', 'image'].include? s.first['type']
          form.push [s.first['name'], s.first['value']]
          form.push [s.first['name'] + '.x', image_x] if image_x > 0
          form.push [s.first['name'] + '.y', image_y] if image_y > 0
        end
      end
      self.xpath('.//input').each do |e|
        next unless e['name']
        case e['type']
        when 'text', 'password', 'hidden', nil
          form.push [e['name'], e['value']]
        when 'radio', 'checkbox'
          form.push [e['name'], e['value']] unless e['checked'].nil?
        when 'file'
          if self['enctype'] =~ %r{^multipart/form-data}i
            f = Pathname.new e['value'].to_s
            form.push [e['name'], f]
          end
        else
          ;
        end
      end
      self.xpath('.//textarea').each do |e|
        form.push [e['name'], e.text]
      end
      self.xpath('.//select').each do |e|
        opt = e.xpath('.//option')
        slctd = opt.reject do |o|
          o['selected'].nil?
        end
        slctd = opt.first if e['multiple'].nil? and slctd.empty?
        slctd.each {|s| form.push([e['name'], s['value']]) } unless slctd.nil?
      end
      form
    end
    
  end
end


