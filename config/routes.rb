Rails.application.routes.draw do
  root "home_pages#top"
  # 利用規約とプライバシーポリシーのルーティング
  get "terms_of_use", to: "home_pages#terms_of_use"
  get "privacy_policy", to: "home_pages#privacy_policy"

  resources :self_records, only: [ :index, :new, :create, :edit, :update, :show, :destroy ]
  resources :conditions, only: [ :index, :new, :create, :edit, :update, :show, :destroy ] do
    collection do
      get "export"
    end
  end
  resources :bodies, only: [ :index, :new, :create, :edit, :update, :show, :destroy ]
  resources :training_menus, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    resources :training_sets, only: [ :new, :create, :edit ] do
      collection do
        patch :update_all
      end
    end
  end

  resources :condition_charts, only: [ :index ]
  resources :body_charts, only: [ :index ]

  devise_for :users, controllers: {
    registrations: "registrations"
  }

  devise_scope :user do
    post "registrations/create_athlete", to: "registrations#create_athlete", as: :registrations_create_athlete
  end

  resources :team_invitations, only: [ :index, :show, :destroy ] do
    member do
      post :approve, :pending
    end
    collection do
      post :generate_url # 招待URL生成用
    end
  end

  post "generate_team_invitation_url", to: "team_invitations#generate_url"

  resources :teams, only: [ :show ] do
    member do
      post :generate_invitation
      get :athletes # 登録状況ページ
    end
  end
  get "teams/:invitation_token/invite", to: "teams#invite", as: :invite_team
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
