class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.integer :order_id, :amount
      t.string :product, :product_description
    end
  end

  def self.down                   
    drop_table :order_items
  end
end
