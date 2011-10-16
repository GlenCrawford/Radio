Radio::Application.routes.draw do
  root :to => "radio#index"

  match "/login" => "users#login", :as => :login
  match "/:action", :controller => "radio", :via => :put
  match "/update/:request" => "radio#update", :via => :get
end
