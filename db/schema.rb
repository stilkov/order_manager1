# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090115101817) do

  create_table "cancellations", :force => true do |t|
    t.date     "cancellation_date"
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items", :force => true do |t|
    t.integer "order_id"
    t.integer "quantity"
    t.string  "product"
    t.string  "product_description"
    t.decimal "price"
  end

  create_table "orders", :force => true do |t|
    t.date     "order_date"
    t.date     "shipping_date"
    t.string   "customer_description"
    t.string   "customer"
    t.string   "billing_address"
    t.string   "shipping_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.decimal  "total",                :precision => 10, :scale => 2
    t.integer  "cancellation_id"
  end

end
