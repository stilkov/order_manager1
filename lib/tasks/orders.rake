namespace :orders do
  namespace :testdata do
    task :create => :delete do
      print "Creating ..."
      (1..100).each do |count|             
        print "."; STDOUT.flush
        customer = rand(10).to_s                        
        s_address = %w(Munich Frankfurt London Chicago Moscow).rand
        b_address = %w(Munich Frankfurt London Chicago Moscow).rand
        order_date = (Time.new - rand(30).days)
        o = Order.new({
          :order_date => order_date,
          :created_at => order_date,
          :updated_at => order_date + rand(30).minutes,
          :shipping_date => order_date + rand(30).days,
          :customer_description => "Customer #{customer}",
          :customer => "http://crm.example.com/customers/#{customer}",
          :billing_address => "#{s_address}",
          :shipping_address => "#{b_address}",
          :state => Order::STATES.rand
        })
        (1 + rand(20)).times do                                            
          product = 1+rand(100)
          o.order_items << OrderItem.new({:quantity => 1+rand(10), 
                                :product => "http://prod.example.com/products/#{product}", 
                                :product_description => "Description for #{product}",
                                :price => [299, 199, 450, 149, 599].rand
                                })
        end
        o.save
      end                     
      puts "done."
    end
    task :delete => :environment do
      print "Deleting ..."; STDOUT.flush
      Order.delete_all
      OrderItem.delete_all
      puts "done."
    end
  end
end
