require 'test_helper'

class CancellationsControllerTest < ControllerTestSupport     
  
test "should get index as XML" do
  @request.env['HTTP_ACCEPT'] = 'application/xml' 
  get :index
  assert_not_nil assigns(:cancellations)
  assert_response :success       
  assert_allows %w(HEAD GET POST)
end

test "should get index" do
  get :index
  assert_response :success
  assert_not_nil assigns(:cancellations)
end

test "should show as XML" do
  @request.env['HTTP_ACCEPT'] = 'application/xml' 
  get :show, :id => cancellations(:one).id
  assert_response :success
end

test "should show cancellation" do
  get :show, :id => cancellations(:one).id
  assert_response :success
end

=begin
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cancellation" do
    assert_difference('Cancellation.count') do
      post :create, :cancellation => { :order_url => order_url(orders(:one)) }
    end

    assert_redirected_to cancellation_path(assigns(:cancellation))
  end
=end

begin
  test "should create order cancellation via XML" do     
    xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<cancellation xmlns="http://example.com/schemas/ordermanagement">
  <date>2009-01-22</date>
  <reason>Unknown</reason>
  <orders>
    <order>%s</order>
  </orders>
</cancellation>    
    XML

    @request.env['RAW_POST_DATA'] = xml % order_url(orders(:one)) 
    @request.env['CONTENT_TYPE'] = 'application/xml'            
    @request.env['HTTP_ACCEPT'] = 'application/xml' 
    post :create
    assert_response :created
    location = @response.header['Location']
    assert_allows %w(HEAD GET PUT DELETE)
    assert_equal cancellation_url(assigns(:cancellation)), location
    order = Order.find(orders(:one).id)
    assert_equal :cancelled, order.state
    assert_equal :accepted, Order.find(orders(:two)).state
  end
end

end
