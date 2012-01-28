Radio::Application.routes.draw do
  root :to => "radio#index"

  match "/admin" => "admin/base#index", :as => :admin
  namespace :admin do
    resources :users
    resources :radio, :only => [:index, :update]
  end

  match "/login" => "users#login", :as => :login
  match "/:action", :controller => "radio", :via => :put
  match "/update/:request" => "radio#update", :via => :get
end
