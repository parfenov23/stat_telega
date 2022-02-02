Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/all", to: "home#all"
  post "/update", to: "home#update"
  get "/history", to: "home#history"
  get "/categories", to: "home#categories"
  get "/add_channels", to: "home#add_channels"
  post "/create_channels", to: "home#create_channels"
  
  resource :jira_webhooks, defaults: { formats: :json } do
    collection do
      post "notify/:project_id", to: "jira_webhooks#notify"
    end
  end
  resource :github_webhooks, only: :create, defaults: { formats: :json }
  
  get "/all_to_archive", to: "home#all_to_archive"

  get "/callback_notify_bot", to: "home#callback_notify_bot"
  post "/callback_notify_bot", to: "home#callback_notify_bot"

  get '/import_all', to: 'home#import_all', as: 'import_all'


  root :to => "home#index"
end
