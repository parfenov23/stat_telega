Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resource :jira_webhooks, defaults: { formats: :json } do
    collection do
      post "notify/:project_id", to: "jira_webhooks#notify"
    end
  end
  resource :github_webhooks, only: :create, defaults: { formats: :json }

  get "/callback_notify_bot", to: "home#callback_notify_bot"
  post "/callback_notify_bot", to: "home#callback_notify_bot"


  post "/create_link", to: "home#create_link" 
  post "/stats", to: "home#stats" 
  get "/:id", to: "home#index" 
  root :to => "home#index"
end
