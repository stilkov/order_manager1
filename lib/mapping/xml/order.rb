require 'xml/libxml'

module Mapping::XML::Order      
  module ClassMethods
    def hash_from_xml(xml)
        doc = (xml.instance_of? String) ? ::XML::Parser.string(xml).parse : ::XML::Parser.io(xml).parse
        ns = 'om:http://example.com/schemas/ordermanagement'
        order_node = doc.find_first('//om:order', ns)
        params = {}
        if order_node
          order_date = order_node.find_first('om:date', ns).try(:content)
          params[:order_date] = Date.parse(order_date) unless order_date.nil?
          shipping_date = order_node.find_first('om:shippingDate', ns).try(:content)
          params[:shipping_date] = Date.parse(shipping_date) unless shipping_date.nil?
          params[:billing_address] = order_node.find_first('om:billingAddress', ns).try(:content)
          params[:shipping_address] = order_node.find_first('om:shippingAddress', ns).try(:content)
          params[:state] = order_node.find_first('om:state', ns).try(:content)
          if customer_node = order_node.find_first('om:customer', ns) then
            params[:customer] = customer_node.find_first("om:link", ns).try(:content)
            params[:customer_description] = customer_node.find_first('om:name', ns).try(:content)
          end
          if items = order_node.find('om:items/om:item', ns) then
            params[:order_items] = items.map do |item|
              { :quantity => item.find_first('om:quantity', ns).try(:content),
                :product => item.find_first('om:product', ns).try(:content),
                :product_description => item.find_first('om:productDescription', ns).try(:content),
                :price => item.find_first('om:price', ns).try(:content) }.delete_if {|key, value| value.nil? }
            end
          end         
        end
        params.delete_if {|key, value| value.nil? }   
    end
    def state_from_xml(xml)
      doc = (xml.instance_of? String) ? ::XML::Parser.string(xml).parse : ::XML::Parser.io(xml).parse
      ns = 'om:http://example.com/schemas/ordermanagement'
      doc.find_first('//om:orderState', ns).try(:content).try(:strip)
    end

    def new_from_xml(xml)
      ::Order.new(::Order.hash_from_xml(xml))
    end      
  end
  
  def update_attributes_from_xml(xml)
    update_attributes(::Order.hash_from_xml(xml))
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
end