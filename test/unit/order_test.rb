require 'test_helper'

class Order
  include Mapping::XML::Order
end


class OrderTest < ActiveSupport::TestCase
  FULL_XML = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<order xmlns="http://example.com/schemas/ordermanagement">
  <date>2008-12-22</date>
  <shippingDate>2009-01-05</shippingDate>
  <customer>
    <name>Customer 5</name>
    <link>http://localhost:3001/customers/5</link>
  </customer>
  <billingAddress>Frankfurt</billingAddress>
  <shippingAddress>Munich</shippingAddress>
</order>    
XML
  
  PARTIAL_XML = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<order xmlns="http://example.com/schemas/ordermanagement">
  <customer>
    <name>Customer 5</name>
    <link>http://localhost:3001/customers/5</link>
  </customer>
  <date>2008-12-22</date>
</order>    
XML
           
  XML_WITH_ITEMS = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<order xmlns="http://example.com/schemas/ordermanagement">
  <date>2008-12-22</date>
  <shippingDate>2009-01-05</shippingDate>
  <customer>
    <name>Customer XYZ</name>
    <link>http://localhost:3001/customers/5</link>
  </customer>
  <billingAddress>Frankfurt</billingAddress>
  <shippingAddress>Munich</shippingAddress>
  <items>
    <item>
      <product>http://example.com/products/231</product>
      <productDescription>MP3 Player</productDescription>
      <quantity>2</quantity>
      <price currency="EUR">199.0</price>
    </item>
    <item>
      <product>http://example.com/products/352</product>
      <productDescription>Laptop X65</productDescription>
      <quantity>1</quantity>
      <price currency="EUR">799.0</price>
    </item>
    <item>
      <product>http://example.com/products/110</product>
      <productDescription>Display 1521T</productDescription>
      <quantity>1</quantity>
      <price currency="EUR">299.0</price>
    </item>
    <item>
      <product>http://example.com/products/123</product>
      <productDescription>1250GB HD</productDescription>
      <quantity>2</quantity>
      <price currency="EUR">199.0</price>
    </item>
  </items>  
</order>    
XML

  test "can be created from complete XML string" do   
    order = Order.new_from_xml(FULL_XML)   
    assert_equal Date.parse("2008-12-22"), order.order_date
    assert_equal Date.parse("2009-01-05"), order.shipping_date
    assert_equal "http://localhost:3001/customers/5", order.customer
    assert_equal "Customer 5", order.customer_description
    assert_equal "Frankfurt", order.billing_address
    assert_equal "Munich", order.shipping_address
  end
  
  test "can be created from IO object" do
    order = Order.new_from_xml(StringIO.new(FULL_XML))
    assert_equal Date.parse("2008-12-22"), order.order_date
    assert_equal Date.parse("2009-01-05"), order.shipping_date
    assert_equal "http://localhost:3001/customers/5", order.customer
    assert_equal "Customer 5", order.customer_description
    assert_equal "Frankfurt", order.billing_address
    assert_equal "Munich", order.shipping_address
  end
  
  test "can be created from partial XML string" do   
    order = Order.new_from_xml(PARTIAL_XML)
    assert_equal Date.parse("2008-12-22"), order.order_date
    assert_equal nil, order.shipping_date
    assert_equal "http://localhost:3001/customers/5", order.customer
    assert_equal "Customer 5", order.customer_description
    assert_equal nil, order.billing_address
    assert_equal nil, order.shipping_address
  end

  test "can be updated from XML string" do   
    order = orders(:one)
    order.update_attributes_from_xml(PARTIAL_XML)
    assert_equal Date.parse("2008-12-22"), order.order_date
    assert_equal "Customer 5", order.customer_description
  end
 
  test "can be created from nested hash" do
    params = {
      :order_date => Date.parse("2008-01-12"),
      :customer => "http://Testcustomer",
      :customer_description => "Test Description",   
      :billing_address => 'New York',
      :order_items => [
        { :quantity => 3, :product => "P1", :product_description => "PD 1", :price => 10 },
        { :quantity => 1, :product => "P2", :product_description => "PD 2", :price => 100 }
        ]
    }
    order = Order.new(params)                                                       
    order.save!
    assert_equal 2, order.order_items.count, "2 order items should have been created"    
    assert_equal "PD 2", order.order_items.find_by_product("P2").product_description
    assert_equal :received, order.state
  end

  test "can be updated from nested hash" do
    order = orders(:one)
    params = {
      :customer_description => "Test Description",   
      :order_items => [
        { :quantity => 3, :product => "P1", :product_description => "PD 1", :price => 10 },
        { :quantity => 1, :product => "P2", :product_description => "PD 2", :price => 100 }
        ]
    }
    order.update_attributes(params)                                                       
    assert_equal 2, order.order_items.count, "order should now have 2 order items"
    assert_equal "PD 2", order.order_items.find_by_product("P2").product_description
  end                                                                             
  
  test "should set order date" do
    hash = { :customer => 'test', :billing_address => 'xyz'}
    o = Order.new(hash)
    assert_not_nil o.order_date
  end
  
  test "should set shipping to billing" do
    hash = { :customer => 'test', :billing_address => 'xyz'}
    o = Order.new(hash)
    assert_equal 'xyz', o.shipping_address
  end

  test "can be created from XML string with items" do   
    order = Order.new_from_xml(XML_WITH_ITEMS)
    order.save!                                                         
    assert_equal 4, order.order_items.length
    assert_equal "MP3 Player", order.order_items.find_by_product("http://example.com/products/231").product_description
    assert_equal 2, order.order_items.find_by_product("http://example.com/products/231").quantity
    assert_equal BigDecimal("199.0"), order.order_items.find_by_product("http://example.com/products/231").price
    assert_equal "Laptop X65", order.order_items.find_by_product("http://example.com/products/352").product_description
    assert_equal 1, order.order_items.find_by_product("http://example.com/products/352").quantity
    assert_equal BigDecimal("799.0"), order.order_items.find_by_product("http://example.com/products/352").price
    assert_equal "Display 1521T", order.order_items.find_by_product("http://example.com/products/110").product_description
    assert_equal 1, order.order_items.find_by_product("http://example.com/products/110").quantity
    assert_equal BigDecimal("299.0"), order.order_items.find_by_product("http://example.com/products/110").price
    assert_equal "1250GB HD", order.order_items.find_by_product("http://example.com/products/123").product_description
    assert_equal 2, order.order_items.find_by_product("http://example.com/products/123").quantity
    assert_equal BigDecimal("199.0"), order.order_items.find_by_product("http://example.com/products/123").price
  end        
  
  
  def test_orders_for_state
    accepted = Order.for_state(:accepted)
    assert_equal 1, accepted.size
    received = Order.for_state(:received)
    assert_equal 1, received.size
    cancelled = Order.for_state(:cancelled)
    assert_equal 2, cancelled.size
    all = Order.for_state(:all)
    assert_equal 4, all.size
    all2 = Order.for_state(nil)
    assert_equal 4, all2.size
  end
end
  

