#require 'xml/libxml'
require 'test_helper'
module ActionController
  module TestProcess
    # Executes a request simulating OPTIONS HTTP method and set/volley the response
    def options(action, parameters = nil, session = nil, flash = nil)
      process(action, parameters, session, flash, "OPTIONS")
    end
  end
end

class OrdersControllerTest < ControllerTestSupport
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
  end
  
  test "should get index as XML" do
    @request.env['HTTP_ACCEPT'] = 'application/xml' 
    get :index
    assert_response :success       
    assert_allows %w(HEAD GET POST)
    orders = assigns(:orders)
    assert_not_nil orders
    assert_equal 4, orders.size
  end
                                 
  test "should get index as XML with state equals all" do
    @request.env['HTTP_ACCEPT'] = 'application/xml' 
    get :index, :state => 'all'
    assert_response :success       
    assert_allows %w(HEAD GET POST)
    orders = assigns(:orders)
    assert_not_nil orders
    assert_equal 4, orders.size
  end

  test "should get orders in state cancelled" do
    @request.env['HTTP_ACCEPT'] = 'application/xml' 
    get :index, :state => :cancelled
    assert_response :success       
    assert_allows %w(HEAD GET POST)
    orders = assigns(:orders)
    assert_not_nil orders
    assert_equal 2, orders.size
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create order" do
    assert_difference('Order.count') do
      post :create, :order => { :customer => 'http://localhost:3001/customers/5', 
                                :order_date => '2008-11-30', 
                                :billing_address => 'New York' }
    end

    assert_redirected_to order_path(assigns(:order))
  end

  test "should create order via XML" do     
    xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<order xmlns="http://example.com/schemas/ordermanagement">
  <date>2009-01-22</date>
  <shippingDate>2009-01-25</shippingDate>
  <customer>
    <name>New customer</name>
    <link>http://localhost:3001/customers/4711</link>
  </customer>
  <billingAddress>Geneva</billingAddress>
  <shippingAddress>Paris</shippingAddress>
</order>    
    XML


    @request.env['RAW_POST_DATA'] = xml
    @request.env['CONTENT_TYPE'] = 'application/xml'            
    @request.env['HTTP_ACCEPT'] = 'application/xml' 
    post :create
    assert_response :created
    location = @response.header['Location']
    assert_allows %w(HEAD GET PUT DELETE)
    assert_equal order_url(assigns(:order)), location
  end


  test "should update order via XML" do     
    xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<order xmlns="http://example.com/schemas/ordermanagement">
  <customer><name>Changed description of customer</name></customer>
</order>    
    XML

    @request.env['RAW_POST_DATA'] = xml
    @request.env['CONTENT_TYPE'] = 'application/xml'            
    @request.env['HTTP_ACCEPT'] = 'application/xml' 
    id = orders(:one).id           
    put :update, :id => id
    assert_response :success
    assert_allows %w(HEAD GET PUT DELETE)
    assert_equal "Changed description of customer", Order.find(id).customer_description 
  end

  test "should show order" do
    get :show, :id => orders(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => orders(:one).id
    assert_response :success
  end

  test "should update order" do
    put :update, :id => orders(:one).id, :order => { }
    assert_redirected_to order_path(assigns(:order))
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete :destroy, :id => orders(:one).id
    end

    assert_redirected_to orders_path
  end 
  
  test "new order should have received state" do
    xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<order xmlns="http://example.com/schemas/ordermanagement">
  <date>2009-01-22</date>
  <shippingDate>2009-01-25</shippingDate>
  <customer>
    <name>New customer</name>
    <link>http://localhost:3001/customers/4711</link>
  </customer>
  <billingAddress>Geneva</billingAddress>
  <shippingAddress>Paris</shippingAddress>
</order>    
    XML


    @request.env['RAW_POST_DATA'] = xml
    @request.env['CONTENT_TYPE'] = 'application/xml'            
    @request.env['HTTP_ACCEPT'] = 'application/xml' 
    post :create
    location = @response.header['Location']
    assert_equal order_url(assigns(:order)), location
    id = assigns(:order).id
    get :show, :id => id
    order = assigns(:order)
    assert_equal order.id, id
    assert_equal :received, order.state.to_sym
    assert_allows %w(HEAD GET PUT DELETE)
  end

  test "options for order collection should be correct" do
    options :options
    assert_response :success
    assert_allows %w(HEAD GET POST)
  end
  
  test "options for order should be correct" do
    options :options, :id => orders(:one).id  
    assert_response :success
    assert_allows %w(HEAD GET PUT DELETE) 
    orders(:one).accept!  
    assert orders(:one).state = :accepted, "Order state should be 'accepted'"
    options :options, :id => orders(:one).id  
    assert_response :success
    assert_allows %w(HEAD GET) 
  end
                         
  test "state resource should reflect order state as plain text" do
      @request.env['HTTP_ACCEPT'] = 'text/plain' 
      get :get_state, :id => orders(:one).id
      assert_response :success
      assert_allows %w(HEAD GET PUT)
      assert_equal "received", @response.body.strip
  end
  
  test "state resource should reflect order state as XML" do
      xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<orderState xmlns="http://example.com/schemas/ordermanagement">received</orderState>
      XML
      @request.env['HTTP_ACCEPT'] = 'application/xml' 
      get :get_state, :id => orders(:one).id
      assert_response :success
      assert_allows %w(HEAD GET PUT)
      assert_dom_equal xml, @response.body 
  end

  test "should create order cancellation via XML" do     
    xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<cancellation xmlns="http://example.com/schemas/ordermanagement">
  <date>2009-01-22</date>
  <reason>Unknown</reason>
</cancellation>    
    XML

    @request.env['RAW_POST_DATA'] = xml.sub('<%= url %>', order_url(orders(:one)))            
    @request.env['CONTENT_TYPE'] = 'application/xml'            
    @request.env['HTTP_ACCEPT'] = 'application/xml' 
    assert_difference('Cancellation.count') do
      post :cancel, :id => orders(:one).id
    end
    assert_response :success
    assert_allows %w(HEAD GET)
    order = Order.find(orders(:one).id)
    assert_equal :cancelled, order.state
    assert_not_nil order.cancellation
    assert_xml @response.body, 'om:http://example.com/schemas/ordermanagement' do |xml|
      xml.assert_node_not_nil '//om:order'
      xml.assert_node_not_nil '//om:order/om:cancellation'
      xml.assert_content_not_nil '//om:order/om:cancellation'
      xml.assert_content_equal cancellation_path(order.cancellation), '//om:order/om:cancellation'
    end
    
  end

  test "order cancellation via XML should fail on accepted orders" do     
    xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<cancellation xmlns="http://example.com/schemas/ordermanagement">
  <date>2009-01-22</date>
  <reason>Unknown</reason>
</cancellation>    
    XML

    @request.env['RAW_POST_DATA'] = xml.sub('<%= url %>', order_url(orders(:one)))            
    @request.env['CONTENT_TYPE'] = 'application/xml'            
    @request.env['HTTP_ACCEPT'] = 'application/xml' 
    assert_no_difference('Cancellation.count') do
      assert_raises(Order::StateError) { post :cancel, :id => orders(:two).id }
    end
  end
end
