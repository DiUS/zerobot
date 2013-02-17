Dashboard::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "authentication" }

  devise_scope :user do
    delete "/users/sign_out" => "devise/sessions#destroy"
    get 'sign_in', :to => 'authentication#sign_in_redirect', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  match '/dashboard' => 'dashboard#index'

  namespace :dashboard do
    # this needs some spring cleaning
    resource :stories, :only => [:create, :show, :destroy] do
      get 'velocity'
    end
    resources :performance
    get 'newrelic/summary', :to => 'performance#summary'
    resource :configurations, :only => [:create, :show] do
      get :keys, :on => :collection
    end
    resources :configurations, :only => [:update] do
      get :export, :on => :collection
    end
  end

  namespace :aws do
    resources :templates, :only => [:index, :show], :constraints => { :id => /[^\/]+(?=\.json\z)|[^\/]+/ }
    resources :stacks, :constraints => { :id => /[^\/]+(?=\.json\z)|[^\/]+/ } do
      get :available, :on => :collection
      get :template, :on => :member
      post :create_ci, :on => :collection
    end

    resources :instances, :constraints => { :id => /i-\S[^\.\/]+/ },
        :only => [:index, :show, :update] do
      get :cost, :on => :collection
    end
  end
  match '/status' => 'status#index'
  match '/status/heart_beat' => 'status#heart_beat'

  match '/launchpad' => 'launchpad#index'
  resources :projects, :only => [:new, :show, :create]

  get "home/index"

  if Rails.configuration.launchpad_enabled
    root :to => 'home#index'
  else
    root :to => 'dashboard#index'
  end

end
