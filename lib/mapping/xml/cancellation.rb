require 'xml/libxml'

module Mapping
  module XML    
    module Cancellation
      module ClassMethods
        def hash_from_xml(xml)
          doc = (xml.instance_of? String) ? ::XML::Parser.string(xml).parse : ::XML::Parser.io(xml).parse
          ns = 'om:http://example.com/schemas/ordermanagement'
          params = {}  
          node = doc.find_first('//om:cancellation',ns)
          params[:reason] = node.find_first('om:reason', ns).try(:content)
          date = node.find_first('om:date', ns).try(:content)
          params[:cancellation_date] = Date.parse(date) unless date.nil?
          if orders = node.find('om:orders/om:order', ns) then
            params[:orders] = orders.map { |node| node.content.split('/').last.to_i }
          end
          params.delete_if {|key, value| value.nil? }   
        end
                                                 
        
        def new_from_xml(xml)       
          ::Cancellation.new(::Cancellation.hash_from_xml(xml))
        end      
      end
      
      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
