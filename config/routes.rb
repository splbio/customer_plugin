Rails.application.routes.draw do
  # Project
#  get "customers/:customer_id", :to => "customers#show"
  get "customers/select", :to => "customers#select"
  post "customers/assign", :to => "customers#assign"

  # Global
  resources :customers
end
