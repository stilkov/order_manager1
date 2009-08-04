class OrdersController < ApplicationController
  Order.send(:include, Mapping::XML::Order)
  Cancellation.send(:include, Mapping::XML::Cancellation)
  
  ALLOWED_METHODS =
    { :received  => "HEAD, GET, PUT, DELETE, OPTIONS",
      :processing  => "HEAD, GET, PUT, OPTIONS",
      :accepted  => "HEAD, GET, OPTIONS",
      :rejected  => "HEAD, GET, OPTIONS",
      :cancelled => "HEAD, GET, OPTIONS",
      :fulfilled => "HEAD, GET, PUT, OPTIONS"
    }
  
  def index
    @order = Order.new
    @state = params['state'].try(:to_sym)
    @order_states = Order::STATES.push(:all).sort { |a,b| a == @state ? -1 : 1}
    @orders = Order.for_state @state
    headers['Allow'] = "HEAD, GET, POST"
    expires_in 60.seconds, :public => true
    respond_to do |format|
      format.html 
      format.xml  
      format.atom 
      format.json { render :json => @orders }
      format.csv { headers['Content-Disposition'] = 'attachment'}
    end
  end

  def root
    expires_in 60.seconds, :public => true
    headers['Allow'] = "HEAD, GET"
    @title = "Overview"
    respond_to do |format|
      format.html # root.html.erb
      format.xml  # root.xml.builder 
    end
  end

  # GET /orders/1
  # GET /orders/1.xml
  def show
    begin
      @order = Order.find(params[:id], :include => :order_items)
      headers['Allow'] = ALLOWED_METHODS[@order.state]
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml # show.xml.builder              
        format.json { render :json => @order.to_json(:include => :order_items) }
      end  
    rescue ActiveRecord::RecordNotFound
        render :text => "No record with id #{params[:id]} found.\n", :status => 404
    end
    
  end
  
  def options
    headers.clear
    id = params[:id]
    if (id) then
     @order = Order.find(id)
      headers['Allow'] = ALLOWED_METHODS[@order.state]
    else
      headers['Allow'] = "HEAD, GET, POST"
    end
    render :nothing => true
  end
  
  # GET /orders/new
  # GET /orders/new.xml
  def new
    
    @title = "Order Entry"
    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.xml
  def create   
    @order = 
      if (request.content_type == 'application/xml') 
        Order.new_from_xml(request.body)
      else
        Order.new(params[:order])
      end

    respond_to do |format|
      if @order.save    
        format.html { redirect_to(@order) }
        format.xml  { render :action => 'show', :status => :created, :location => @order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.xml
  def update             
    begin
      @order = Order.find(params[:id])                   
      
      success = # @order.update_attributes(request.xml? ? request.body : params[:order])
        # if request.xml?
        if (request.content_type == 'application/xml') then
          @order.update_attributes_from_xml(request.body)
        else
          @order.update_attributes(params[:order])
        end
      
      respond_to do |format|
        if success
          format.html { redirect_to(@order) }
          format.xml  { render :action => 'show' }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
        end
      end
    rescue ActiveRecord::RecordNotFound
        render :text => "No record with id #{params[:id]} found.\n", :status => 404
    end
    
  end

  def get_state
    @order = Order.find(params[:id])
    respond_to do |format|
      format.html
      format.xml  
      format.text { render :text => "#{@order.state.to_s}\n" }
    end
  end  
  
  
  def set_state
    @order = Order.find(params[:id])
    @order.state = case request.content_type
      when 'application/vnd.example.com-ordermanagement+xml':
        Order.state_from_xml(request.body)
      when 'text/plain'
        request.body.read.strip
      end
    if @order.save! then
      respond_to do |format|
        format.text  { render :text => "#{@order.state.to_s}\n" }
        format.xml  { render :action => 'get_state' }
      end
    else 
      respond_to do |format|
        format.text  { render :text => @order.errors.inspect, :status => :unprocessable_entity }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end  

  def get_shipping
    @order = Order.find(params[:id])
    respond_to do |format|
      format.text { render :text => "#{@order.shipping_address}\n" }
    end
  end  

  
  def set_shipping
    @order = Order.find(params[:id])
    @order.shipping_address = case request.content_type
      when 'text/plain'
        request.body.read.strip
      end
    if @order.save! then
      respond_to do |format|
        format.text  { render :text => "#{@order.shipping_address}\n" }
        format.xml  { render :action => 'get_state' }
      end
    else 
      respond_to do |format|
        format.text  { render :text => @order.errors.inspect, :status => :unprocessable_entity }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end  

  def cancel
    begin
      @order = Order.find(params[:id])
      @cancellation = 
        if (request.content_type == 'application/xml') 
          Cancellation.new_from_xml(request.body.read)
        else
          Cancellation.new(params[:order])
        end
      @cancellation.orders << @order
      respond_to do |format|
        if @cancellation.save! && @order.save!    
          format.html { redirect_to(@order) }
          format.xml  { render :action => 'show' }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
        end
      end    
    rescue ActiveRecord::RecordNotFound
        render :text => "No record with id #{params[:id]} found.\n", :status => 404
    rescue Order::StateError => e
      render :text => "#{e.message}\n", :status => 400
    end
  end

  def get_cancellation
    cancellation = Order.find(params[:id]).try(:cancellation)
    redirect_to cancellation
  end
    
  # DELETE /orders/1
  # DELETE /orders/1.xml
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to(orders_url) }
      format.xml  { head :ok }
    end
  end
end
