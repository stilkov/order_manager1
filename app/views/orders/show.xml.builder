xml.instruct! :xml, :encoding => "UTF-8"
xml.order :xmlns => 'http://example.com/schemas/ordermanagement', 'xml:base' => base_uri, :href => order_path(@order) do
  xml.link :rel => 'customer', :title => @order.customer_description, :ref => @order.customer
  xml.date @order.order_date.xmlschema
  xml.state @order.state.to_s
  xml.link :rel => 'update-state', :ref => 'state'
  xml.cancellation cancellation_path(@order.cancellation) unless @order.cancellation.nil?
  xml.shippingDate @order.shipping_date.try(:xmlschema)
  xml.billingAddress @order.billing_address
  xml.shippingAddress @order.shipping_address
  xml.total @order.total, :currency => 'EUR' 
  if @order.order_items then
    xml.items {
    @order.order_items.each do |item|
      xml.item {
        xml.product item.product
        xml.productDescription item.product_description
        xml.quantity item.quantity
        xml.price item.price, :currency => 'EUR' 
      }
    end
   }
 end
end