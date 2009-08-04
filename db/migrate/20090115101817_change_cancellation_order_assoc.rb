class ChangeCancellationOrderAssoc < ActiveRecord::Migration
  def self.up
    remove_column :cancellations, :order_id
    add_column :orders, :cancellation_id, :integer
  end

  def self.down
    add_column :cancellations, :order_id
    remove_column :orders, :cancellation_id
  end
end
