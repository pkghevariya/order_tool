module OrderHelper
	def order_status_change
		['fulfilled','partial','restocked','unfulfilled'].each do |order_status|
            @order_note = @order.note.gsub("order status updated to #{order_status}",'')
        end
        @order.update_attributes(note: "#{@order_note} order status updated to #{@order_status}")
        @order_updated = true
	end
end
