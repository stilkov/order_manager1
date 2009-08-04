class AddItemPrice < ActiveRecord::Migration
  def self.up
    add_column :order_items, :price, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    remove_column :order_items, :price
  end
end
