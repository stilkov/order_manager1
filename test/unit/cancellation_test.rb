require 'test_helper'

class Cancellation
  include Mapping::XML::Cancellation
end


class CancellationTest < ActiveSupport::TestCase
  test "should be created from XML" do
    xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<cancellation xmlns="http://example.com/schemas/ordermanagement">
  <date>2009-01-22</date>
  <reason>Unknown</reason>
  <orders><order>http://test/<%= id %></order></orders>
</cancellation> 
XML
   
    
    xml.sub! '<%= id %>', orders(:one).id.to_s 
    cancellation = Cancellation.new_from_xml(xml)
    assert_equal "Unknown", cancellation.reason
    cancellation.orders.each { |o| assert_equal :cancelled, o.state }
    cancellation.save!
    order = Order.find(orders(:one).id)
    assert_equal :cancelled, order.state
  end  
  
  test "should cancel order when created with everything" do
    order = Order.find(orders(:one).id)
    assert_equal :received, order.state
    cancellation = Cancellation.new(:cancellation_date => Date.parse("2009-01-22"), :reason => 'whatever',
                                         :orders => [ orders(:one).id ])
    cancellation.save!
    order = Order.find(orders(:one).id)
    assert_equal :cancelled, order.state
  end
  
  test "should cancel order when created without order id" do
    order = Order.find(orders(:one).id)
    assert_equal :received, order.state
    cancellation = Cancellation.new(:cancellation_date => Date.parse("2009-01-22"), :reason => 'whatever')
    cancellation.orders << order
    cancellation.save!
    cancellation_id = cancellation.id
    assert_equal :cancelled, order.state
    order.save!
    order = Order.find(orders(:one).id)
    assert_equal :cancelled, order.state
    assert_equal cancellation.id, order.cancellation.id 
  end

  test "should not cancel order in state accepted" do
    order = Order.find(orders(:two).id)
    assert_equal :accepted, order.state
    cancellation = Cancellation.new(:cancellation_date => Date.parse("2009-01-22"), :reason => 'whatever')
    assert_raises(Order::StateError) { cancellation.orders << order }
  end  
end
  

