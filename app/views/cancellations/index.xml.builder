xml.instruct! :xml, :encoding => "UTF-8"
xml.orderCancellations :xmlns => 'http://example.com/schemas/ordermanagement', 'xml:base' => base_uri do
   @cancellations.each do |c|
     xml.cancellation :href => cancellation_path(c), :xmlns => 'http://example.com/schemas/ordermanagement' do
       xml.date c.cancellation_date.xmlschema
       xml.reason c.reason
     end
  end
end