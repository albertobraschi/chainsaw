

module Nokogiri
  module XML
    class Node
      def fix_xpath(*paths)
        paths.map do |path|
          if path.is_a? String
            # fix for id() func
            path.sub(/^id\(\s*["']([^"']*)["']\s*\)/, './/*[@id="\1"]')
          else
            path
          end
        end
      end

      alias original_search search
      def search(*paths)
        original_search(*fix_xpath(*paths))
      end
      
      alias original_xpath xpath
      def xpath(*paths)
        original_xpath(*fix_xpath(*paths))
      end

    end
  end
end