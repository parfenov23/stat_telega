# require 'sidekiq/web'
# require 'sidekiq/cron/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  # mount Sidekiq::Web, at: "/activejob-44bd34a845a5"
  
  resource :jira_webhooks, defaults: { formats: :json } do
    collection do
      post "notify/:project_id", to: "jira_webhooks#notify"
    end
  end

  get "/callback_notify_bot", to: "home#callback_notify_bot"
  post "/callback_notify_bot", to: "home#callback_notify_bot"


  post "/create_link", to: "home#create_link" 
  post "/stats", to: "home#stats" 
  post "/update_short_links", to: "home#update_short_links" 
  get '/upload_sessions', to: 'home#upload_sessions'
  post '/unzip_sessions', to: 'home#unzip_sessions'
  get "/:id", to: "home#index" 
  root :to => "home#index"
end
