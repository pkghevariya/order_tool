ShopifyApp.configure do |config|
  config.application_name = "Order Tool"

  # ==========development=================
  config.api_key = '63600ce01a24e1db61267c3855b339a9'
  config.secret = 'a60dee96ffb8f6ddeeb321d70a2ea3ff'

  # ==========production=================
  # config.api_key = 'c40fcdd4a8ec9a0d615a4e4307f6b7bf'
  # config.secret = '3aacf0c182fc82056708baa9dd8ec43e'

  config.scope = "write_orders, write_products"
  config.embedded_app = true
  config.after_authenticate_job = false
  config.session_repository = Shop
  config.webhooks = [
    {topic: 'orders/update', address: "https://#{ENV['domain']}/webhooks/order_update", format: 'json'},
    {topic: 'orders/create', address: "https://#{ENV['domain']}/webhooks/order_create", format: 'json'},
  ]
end
