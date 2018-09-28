Rails.application.routes.draw do
  root :to => 'order_tool#instructions'
  post 'test/update_order_status'
  get 'home/screen_1'
  get 'order_tool/home'
  mount ShopifyApp::Engine, at: '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
