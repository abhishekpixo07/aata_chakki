Rails.application.routes.draw do
  # scope(path: '/') { draw :storefront }
  
  mount SolidusAdmin::Engine, at: '/admin', constraints: ->(req) {
    req.cookies['solidus_admin'] != 'false' &&
    req.params['solidus_admin'] != 'false'
  }

  mount SolidusStripe::Engine, at: '/solidus_stripe'

  root to: 'home#index'

  get 'new/subscription/plan', to: 'spree/admin/subscriptions#new_subscription_plan'
  post 'create_subscription_plan', to: 'spree/admin/subscriptions#create_subscription_plan'
  
  get 'edit/subscription/plan/:id', to: 'spree/admin/subscriptions#edit_subscription_plan', as: 'edit_subscription_plan'
  patch 'update/subscription/plan/:id', to: 'spree/admin/subscriptions#update_subscription_plan', as: 'update_subscription_plan'

  devise_for(:user, {
    class_name: 'Spree::User',
    singular: :spree_user,
    controllers: {
      sessions: 'user_sessions',
      registrations: 'user_registrations',
      passwords: 'user_passwords',
      confirmations: 'user_confirmations'
    },
    skip: [:unlocks, :omniauth_callbacks],
    path_names: { sign_out: 'logout' }
  })

  resources :users, only: [:edit, :update]

  devise_scope :spree_user do
    get '/login', to: 'user_sessions#new', as: :login
    post '/login', to: 'user_sessions#create', as: :create_new_session
    match '/logout', to: 'user_sessions#destroy', as: :logout, via: Devise.sign_out_via
    get '/signup', to: 'user_registrations#new', as: :signup
    post '/signup', to: 'user_registrations#create', as: :registration
    get '/password/recover', to: 'user_passwords#new', as: :recover_password
    post '/password/recover', to: 'user_passwords#create', as: :reset_password
    get '/password/change', to: 'user_passwords#edit', as: :edit_password
    put '/password/change', to: 'user_passwords#update', as: :update_password
    get '/confirm', to: 'user_confirmations#show', as: :confirmation if Spree::Auth::Config[:confirmable]
    get '/enter/otp/:id', to: 'user_registrations#enter_otp', as: :enter_otp
    post '/confirm_otp', to: 'user_registrations#confirm_otp', as: :confirm_otp
    get 'user/susbscription', to: 'users#user_susbscription', as: :user_susbscription
    post 'create_subscription', to: 'users#create_subscription'
    post 'update_subscription', to: 'users#update_subscription'
  end

  get '/about_us', to: 'home#about_us', as: 'about_us'
  get '/contact_us', to: 'home#contact_us', as: 'contact_us'

  resource :account, controller: 'users'

  resources :products, only: [:index, :show]

  resources :autocomplete_results, only: :index

  resources :cart_line_items, only: :create

  get '/locale/set', to: 'locale#set'
  post '/locale/set', to: 'locale#set', as: :select_locale

  resource :checkout_session, only: :new
  resource :checkout_guest_session, only: :create

  patch '/checkout/update/:state', to: 'checkouts#update', as: :update_checkout
  get '/checkout/:state', to: 'checkouts#edit', as: :checkout_state
  get '/checkout', to: 'checkouts#edit', as: :checkout

  get '/orders/:id/token/:token' => 'orders#show', as: :token_order

  resources :orders, only: :show do
    resources :coupon_codes, only: :create
  end

  resource :cart, only: [:show, :update] do
    put 'empty'
  end

  get '/t/*id', to: 'taxons#show', as: :nested_taxons

  get '/unauthorized', to: 'home#unauthorized', as: :unauthorized
  get '/cart_link', to: 'store#cart_link', as: :cart_link

  mount Spree::Core::Engine, at: '/'
end