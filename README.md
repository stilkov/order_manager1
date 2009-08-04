## Order Manager: Sample Application for "REST & HTTP" by Stefan Tilkov

### Quick intro (not really useful if you don't know Rails):

* create database with `rake db:create`
* migrate to correct DB schema with `rake db:migrate#´`
* start the server with script/server
* set up a proxy forwarding, e.g. using Apache, from om.example.com:80 to localhost:3000. If you don't know how to do this, replace om.example.com below with localhost:3000

Then you can try a few things:

#### Get a list of all orders

    curl -i http://om.example.com/orders -H 'Accept: application/xml'

####  Pick one of the order links and follow it

    curl -i http://om.example.com/orders/1054584184 -H 'Accept: application/xml'

#### Submit a new order


    curl -i -X POST -H 'Accept: application/xml' -H 'Content-type: application/xml' http://om.example.com/orders -d '<order xmlns="http://example.com/schemas/ordermanagement">
      <customer>
        <name>Prof. Bienlein</name>
        <link>http://crm.example.com/customers/0815</link>
      </customer>
      <billingAddress>Bruxelles, Belgium</billingAddress>
      <items>
        <item>
          <product>http://prod.example.com/products/352</product>
          <productDescription>Laptop X65</productDescription>
          <quantity>2</quantity>
          <price currency="EUR">799.0</price>
        </item>
      </items>
    </order>'

#### Update an existing order


	curl -i -X PUT  -H 'Accept: application/xml' -H 'Content-type: application/xml' http://om.example.com/orders/1054583387 -d '<order xmlns="http://example.com/schemas/ordermanagement">
	   <customer>
	     <name>Prof. Bienlein</name>
	     <link>http://crm.example.com/customers/0815</link>
	   </customer>
	   <billingAddress>Bruxelles, Belgium</billingAddress>
	   <shippingAddress>Paris, France</shippingAddress>
	   <items>
	     <item>
	       <product>http://prod.example.com/products/352</product>
	       <productDescription>Laptop X65</productDescription>
	       <quantity>2</quantity>
	       <price currency="EUR">799.0</price>
	     </item>
	   </items>
	 </order>'
	
#### Cancel an order

    curl -i -X POST http://om.example.com/orders/1054583387 -H 'Accept: application/xml' -H 'Content-type: application/xml' -d '<cancellation xmlns="http://example.com/schemas/ordermanagement">
       <date>2009-01-22</date>
       <reason>Changed my mind</reason>
     </cancellation> '
    


#### Cancel several orders at once

	curl -i -X POST -H 'Accept: application/xml' -H 'Content-type: application/xml' http://om.example.com/cancellations -d '<cancellation xmlns="http://example.com/schemas/ordermanagement">
	  <date>2009-01-22</date>
	  <reason>Totally lost interest</reason>
	  <orders>
	<order>http://om.example.com/orders/953125641</order>
	<order>http://om.example.com/orders/1054583384</order>
	  </orders>
	</cancellation>

You can also try to connect to the server from your browser and admire the awesome HTML being returned.

See http://rest-http.info for more information.