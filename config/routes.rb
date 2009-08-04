ActionController::Routing::Routes.draw do |map|    
  
  map.with_options :controller=>"orders" do |m|
    m.new_order '/orders/new',            :action => 'new',       :conditions => { :method => :get }
    m.orders '/orders',                   :action => 'index',     :conditions => { :method => :get }
    m.formatted_orders '/orders.:format',                   :action => 'index',     :conditions => { :method => :get }
    m.orders '/orders',                   :action => 'create',    :conditions => { :method => :post }
    m.order '/orders/:id',                :action => 'show',      :conditions => { :method => :get }
    m.formatted_order '/orders/:id.:format',                :action => 'show',      :conditions => { :method => :get }
    m.order '/orders/:id',                :action => 'update',    :conditions => { :method => :put }
    m.order '/orders/:id',                :action => 'destroy',   :conditions => { :method => :delete }
    m.connect '/orders/:id',              :action => 'cancel',    :conditions => { :method => :post }
    m.connect '/orders/:id/cancellation', :action => 'get_cancellation',    :conditions => { :method => :get }
    m.edit_order '/orders/:id/edit',      :action => 'edit',      :conditions => { :method => :get }
    m.order_options '/orders/:id',        :action => 'options',   :conditions => { :method => :options }
    m.order_state '/orders/:id/state',    :action => 'get_state', :conditions => { :method => :get }
    m.order_state '/orders/:id/state',    :action => 'set_state', :conditions => { :method => :put }
    m.order_state '/orders/:id/shipping',    :action => 'get_shipping', :conditions => { :method => :get }
    m.order_state '/orders/:id/shipping',    :action => 'set_shipping', :conditions => { :method => :put }
    m.root                                :action => "root"     
  end

  map.history '/orders/:year/:month/:day/*hour',  
    :controller => 'history', :action => 'index',
    :conditions => { :method => :get }
  
  map.resources :cancellations

  
end
