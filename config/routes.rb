Rails.application.routes.draw do
  get "customers/:customer_id", :to => "customers#show"
  get "customers/select", :to => "customers#select"
  post "customers/assign", :to => "customers#assign"

  # TODO: Convert to REST
  get "customers/list", :to => "customers#list"
  get "customers/new", :to => "customers#new"
  post "customers", :to => "customers#create"
  get "customers/", :to => "customers#show"
  get "customers/:customer_id/edit", :to => "customers#edit"
  put "customers/:customer_id", :to => "customers#update"
  delete "customers/:customer_id", :to => "customers#destroy"
end
