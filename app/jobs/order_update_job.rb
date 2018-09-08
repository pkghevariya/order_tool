class OrderUpdateJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    shop.with_shopify_session do
    	
    	@order_status = webhook['fulfillment_status']
    	webhook['line_items'].each do |line_item|
    		@is_digital = line_item.requires_shipping
    	end
    	@shipping_company = webhook['shipping_lines'][0].title rescue ''
    	@tracking_no = ''#not found
    	@order_id = webhook['id']
    	@shop_domain = shop_domain #unique identifier
      @result = shop.order_call(@order_status,@is_digital,@shipping_company,@tracking_no,@shop_domain)

			#update order note
			@order = ShopifyAPI::Order.find(webhook['id'])
      @order_updated = false
    	if @result.response.code == 200
    		@order.update(note: "order status updated to #{@order_status}")
    	else
        for i in 0..1
          @result = shop.order_call(@order_status,@is_digital,@shipping_company,@tracking_no,@shop_domain)
          if @result.response.code == 200
            @order.update(note: "order status updated to #{@order_status}")
            @order_updated = true
            break
          end
        end
    		@order.update(note: "Error message here") unless @order_updated
    	end
    end
  end
end
