class OrderUpdateJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    shop.with_shopify_session do
    	
    	@order_status = webhook['fulfillment_status']
    	webhook['line_items'].each do |line_item|
    		@is_digital = line_item.requires_shipping
    	end
    	@shipping_company = webhook['shipping_lines'][0].title rescue ''
    	# @tracking_no = not found
    	@order_id = webhook['id']
    	@shop_domain = shop_domain #unique identifier
    	@result = HTTParty.post("https://order-tool.herokuapp.com/home/update_order_status", 
	    :body => { :order_status => @order_status, 
	               :is_digital => @is_digital, 
	               :shipping_company => @shipping_company, 
	               :tracking_no => @tracking_no, 
	               :shop_domain => @shop_domain
	             }.to_json,
	    :headers => { 'Content-Type' => 'application/json' } )

			#update order note
			@order = ShopifyAPI::Order.find(webhook['id'])
    	if @result
    		@order.update(note: "order status updated to #{@order_status}")
    	else
    		@order.update(note: "Error message here")
    	end
    end
  end
end
