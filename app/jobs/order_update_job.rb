class OrderUpdateJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    shop.with_shopify_session do
      puts "Order Update Webhook called..........."
      # do nothing if already processed
      if @order.note != "order status updated to #{@order_status}"
      	@order_status = webhook['fulfillment_status']
      	@order_status = 'unfulfilled' unless @order_status.present?
      	webhook['line_items'].each do |line_item|
      		@is_digital = !line_item["requires_shipping"]
      	end
      	@shipping_company = webhook['shipping_lines'][0]['title'] rescue ''
        @tracking_no = webhook['fulfillments'][0]['tracking_number'] rescue nil
      	@tracking_company = webhook['fulfillments'][0]['tracking_company'] rescue nil
      	@order_id = webhook['id']
      	@shop_domain = shop_domain #unique identifier
        # process only if gateway is paypal and tracking info presents.
        if webhook['gateway'].downcase == "paypal" && @tracking_no.present? && @tracking_company.present?
          puts "Gateway===#{webhook['gateway'].downcase}"
          puts "Tracking No:===#{@tracking_no}"
          puts "Tracking Company:===#{@tracking_company}"
          @result = shop.order_call(@order_status,@is_digital,@shipping_company,@tracking_no,@shop_domain)

    			#update order note
    			@order = ShopifyAPI::Order.find(webhook['id'])
          @order_updated = false
        	if @result.response.code == '200'
            puts "Upper Partttttt"
        		@order.update_attributes(note: "order status updated to #{@order_status}")
        		@order_updated = true
        	else
            for i in 0..1
              @result = shop.order_call(@order_status,@is_digital,@shipping_company,@tracking_no,@shop_domain)
              if @result.response.code == '200'
                puts "Down Parttttttt"
                @order.update_attributes(note: "order status updated to #{@order_status}")
                @order_updated = true
                break
              end
            end
        		@order.update_attributes(note: "Error message here") if @order.note != "Error message here" && !@order_updated
        	end
        else
          puts "nothing happens"
        end
      else
        puts "status already updated"
      end
    end
  end
end
