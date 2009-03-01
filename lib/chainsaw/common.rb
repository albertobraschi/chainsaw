
module Chainsaw
  
  module Util
    
    def is_xml_parsable?(content_type)
      content_type =~ %r{(?:text|application)/x?(?:ht)?ml}
    end
    
    def to_nth(num)
      case num.to_i
      when 1
        '1st'
      when 2
        '2nd'
      when 3
        '3rd'
      else
        num.to_i.to_s + 'th'
      end
    end
    
    def qq(str)
      "\"#{str}\""
    end
  end
  
  module Encoding
    NKF_TO_LIBXML2 = {
      NKF::ASCII   => 10, #=> 22,
      NKF::JIS     => 19,
      NKF::SJIS    => 20,
      NKF::EUC     => 21,
      NKF::UTF8    => 1,
      NKF::UTF16   => 2,
      NKF::UNKNOWN => 10,
      NKF::BINARY  => 10,
    }
    
    def self.guess(data)
      nokogiri_consts = Nokogiri::XML::SAX::Parser::ENCODINGS
      nkf_guessed = NKF.guess data
      value = NKF_TO_LIBXML2[nkf_guessed]
      value = NKF_TO_LIBXML2[NKF::UTF8] unless nokogiri_consts.value?(value)
      c = nokogiri_consts.find do |k, v|
        v == value
      end
      c.first
    end
  end
  
  module ErrorWrapper
    APPLY_TESTUNIT_BACKTRACEFILTER = true
    @@indent = '| '
    @@tab = '  '
    def set_backtrace(backtrace)
      root_cause = $!
      unless root_cause.nil?
        backtrace = filter_backtrace(backtrace)
        backtrace.push '............', 'root cause'
        backtrace.push "#{@@indent}#{root_cause.class.name}: #{root_cause.to_s}"
        backtrace.concat(filter_backtrace(root_cause.backtrace).map do |t|
          "#{@@indent}#{@@tab}#{t}"
        end)
      end
      super backtrace
    end
    
    def filter_backtrace(backtrace)
      if APPLY_TESTUNIT_BACKTRACEFILTER
        require 'test/unit/util/backtracefilter'
        Test::Unit::Util::BacktraceFilter.module_eval do
          module_function :filter_backtrace
        end
        Test::Unit::Util::BacktraceFilter.filter_backtrace backtrace
      else
        backtrace
      end
    end
  end
  
  class RequestError < StandardError
    include Chainsaw::ErrorWrapper
  end
  
end

