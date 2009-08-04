xml.instruct! :xml, :encoding => "UTF-8"
xml.orderState @order.state.to_s, :xmlns => 'http://example.com/schemas/ordermanagement'