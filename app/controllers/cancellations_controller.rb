class CancellationsController < ApplicationController
  Cancellation.send(:include, Mapping::XML::Cancellation)
  # GET /cancellations
  # GET /cancellations.xml
  def index
    @cancellations = Cancellation.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  # index.xml.builder
    end
  end

  # GET /cancellations/1
  # GET /cancellations/1.xml
  def show
    @cancellation = Cancellation.find(params[:id])
    @orders = @cancellation.orders
    respond_to do |format|
      format.html # show.html.erb
      format.xml  # show.xml.builder
    end
  end

  # GET /cancellations/new
  # GET /cancellations/new.xml
  def new
    @cancellation = Cancellation.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /cancellations
  # POST /cancellations.xml
  def create
    @cancellation = Cancellation.new_from_xml(request.body.read)
    respond_to do |format|
      if @cancellation.save!    
        format.xml  { render :action => 'show', :status => :created, :location => @cancellation }
      else
        format.xml  { render :xml => @cancellation.errors, :status => :unprocessable_entity }
      end
    end    
    
    #@orders.each do |order|
  end

end
