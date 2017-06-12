Rails.application.routes.draw do

  root 'bjond_registrations#index'

  post '/shopify/orderscreated' => 'orders#creation'
end
