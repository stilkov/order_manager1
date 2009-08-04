xml.instruct! :xml, :encoding => "UTF-8"
xml.orders :xmlns => 'http://example.com/schemas/ordermanagement', 'xml:base' => base_uri do
   @orders.each { |o|
    xml.order :href => order_path(o) do 
      xml.customer do
        xml.name o.customer_description
        xml.link o.customer
      end
      xml.date o.order_date.xmlschema
      xml.status o.state.to_s
      xml.total o.total, :currency => 'EUR'
    end
  }
end