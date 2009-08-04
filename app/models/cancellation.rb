class Cancellation < ActiveRecord::Base     
  has_many :orders, :foreign_key => "cancellation_id", :after_add => 'cancel_order!' 
  validates_presence_of :cancellation_date, :reason 
  
  def initialize(hash = {})
    orders = hash.delete(:orders) || []
    super(hash)                 
    orders.each do |id| 
      order = Order.find(id)
      order.cancel!(self)
      order.save!
    end
  end
  
  def cancel_order!
    orders.each { |order| order.cancel!(self) }
  end
end
