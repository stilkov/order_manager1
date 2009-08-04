class RenameAmountToQuantity < ActiveRecord::Migration
  def self.up
    rename_column :order_items, :amount, :quantity
  end

  def self.down
    rename_column :order_items, :quantity, :amount
  end
end
