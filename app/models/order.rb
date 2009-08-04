class Order < ActiveRecord::Base     
  class StateError < StandardError
  end

  STATES = [ :received, :accepted, :processing, :rejected, :cancelled, :fulfilled ]
  
  has_many :order_items, :dependent => :destroy 
  belongs_to :cancellation, :class_name => "Cancellation", :foreign_key => "cancellation_id" # optionally, of course      
  validates_presence_of :customer, :order_date, :billing_address
  
  symbolize :state, :in => STATES
  
  # design smell - initialize nicht überschreiben ? passender hook? 
  def initialize(hash = {})   
    items = hash.delete(:order_items) || []
    hash[:order_date] ||= Time.now
    hash[:shipping_address] ||= hash[:billing_address]
    super(hash)
    items.map { |item| self.order_items.build(item) }     
    self.state = :received unless hash[:state]
  end            
    
  # look for items= !
  
  def update_attributes_with_nesting(hash)   
    items = hash.delete(:order_items) || []
    update_attributes_without_nesting(hash)                        
    self.order_items.delete_all
    items.map { |item| self.order_items.create(item) }
    save!
  end                

  alias_method_chain :update_attributes, :nesting

  def cancel!(cancellation)
    if self.state == :received then 
      self.state = :cancelled
      self.cancellation = cancellation
    else
      raise StateError, "Order in state '#{self.state.to_s}' cannot be cancelled"
    end
  end                               
             
  # symbolize raus, lieber meta-vodoo hier
  def accept!
    self.state = :accepted
  end
  
  def total
    read_attribute(:total) || write_attribute(:total, order_items.inject(0) {|sum, n| sum + n.quantity * n.price })
  end
  
  before_save { |order| order.total }
  
  def self.for_state(state) 
    state.nil? || state == :all ? Order.find(:all) : Order.find(:all, :conditions => [ "state = ?", state])
  end
end