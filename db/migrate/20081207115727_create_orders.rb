class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.date :order_date
      t.date :shipping_date
      t.string :customer_description
      t.string :customer
      t.string :billing_address
      t.string :shipping_address

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
