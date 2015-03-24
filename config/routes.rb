Rails.application.routes.draw do
  # Project
  get "projects/:id/customer", :to => "customers#show"
  get "projects/:id/customer/select", :to => "customers#select"
  post "projects/:id/customer", :to => "customers#assign"

  # Global
  resources :customers, :except => :show
end
