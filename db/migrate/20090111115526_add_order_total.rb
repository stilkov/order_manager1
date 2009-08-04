class AddOrderTotal < ActiveRecord::Migration
  def self.up
    add_column :orders, :total, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    remove_column :orders, :total
  end
end
