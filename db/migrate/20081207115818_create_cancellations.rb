class CreateCancellations < ActiveRecord::Migration
  def self.up
    create_table :cancellations do |t|
      t.date :cancellation_date
      t.integer :order_id
      t.string :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :cancellations
  end
end
