Rails.application.routes.draw do
  # root :to => 'home#index'
  root :to => 'order_tool#dashboard'
  get 'order_tool/instructions'
  get 'contact_us' ,to: 'order_tool#contact_us'
  post 'test/update_order_status'
  mount ShopifyApp::Engine, at: '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/billing/callback', to: 'home#callback', as: :billing_callback
end
