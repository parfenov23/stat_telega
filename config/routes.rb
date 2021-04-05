Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/all", to: "home#all"
  post "/update", to: "home#update"
  get "/history", to: "home#history"
  get "/categories", to: "home#categories"
  get "/add_channels", to: "home#add_channels"
  post "/create_channels", to: "home#create_channels"
  get "/all_to_archive", to: "home#all_to_archive"


  root :to => "home#index"
end
