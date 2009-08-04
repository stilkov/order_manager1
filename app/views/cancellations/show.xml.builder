xml.instruct! :xml, :encoding => "UTF-8"
xml.cancellation :xmlns => 'http://example.com/schemas/ordermanagement' do
  xml.date @cancellation.cancellation_date.xmlschema
  xml.reason @cancellation.reason
  xml.orders {
    @cancellation.orders.each do |order|
      xml.order :href => order_url(order)
    end
  }
end