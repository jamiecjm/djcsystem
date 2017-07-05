require 'subdomain'

Rails.application.routes.draw do

      constraints(Subdomain) do

        root 'mains#index'

        resources :websites

        devise_for :users, :controllers => { registrations: 'registrations', passwords: 'passwords' }
        resources :users, except: [:show]

        mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
        resources :teams
        resources :commissions
        resources :salevalues
        resources :sales
        resources :units
        
        get '/users/:user_id/sales' => "users#sales"
        post '/users/:user_id/sales' => "users#sales"
        get '/requests' => "users#requests"
        post '/request' => "users#approve"
        get '/approve' => "users#approve"
        post '/change_user' => 'users#change_user'
        get '/revert_user' => 'users#revert_user'

        get '/dashboard' => "pages#dashboard"
        get '/pages/sales' => "pages#sales"
        get '/pages/units' => "pages#units"
        get '/pages/users' => "pages#users"


        # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
        resources :sales, controller: "sales"
        post '/change_status' => "sales#change_status"
        post '/sales/email' => "sales#email"

        resources :teams, controller: "teams"
        get '/teams/:team_id/sales' => "teams#sales"
        post '/teams/:team_id/sales' => "teams#sales"
        get '/teams_sales_summary' => "teams#members" 
        post '/teams_sales_summary' => "teams#members" 
        get '/teams/:team_id/profiles' => "teams#profiles"

        
        get '/charts/uptodate/barchart' => "charts#uptodate_barchart"
        get '/charts/monthly_barchart' => "charts#monthly_barchart"
        post '/charts/barchart' => "charts#barchart"
        get '/charts/barchart' => "charts#barchart"

        resources :projects

        post '/search_by_name' => 'searches#search_by_name'
        post '/search_team_sales' => 'searches#search_team_sales'
        get '/search_team_sales' => 'searches#search_team_sales'
        post '/search_individual_sales' => 'searches#search_individual_sales'
        get '/search_individual_sales' => 'searches#search_individual_sales'
      end

    # redirect to root if no routes matches, must be at the last line
    get '*path' => redirect('/')
end

# Session routes for Authenticatable (default)
 #     new_user_session GET    /users/sign_in                    {controller:"devise/sessions", action:"new"}
 #         user_session POST   /users/sign_in                    {controller:"devise/sessions", action:"create"}
 # destroy_user_session DELETE /users/sign_out                   {controller:"devise/sessions", action:"destroy"}

# Password routes for Recoverable, if User model has :recoverable configured
   #  new_user_password GET    /users/password/new(.:format)     {controller:"devise/passwords", action:"new"}
   # edit_user_password GET    /users/password/edit(.:format)    {controller:"devise/passwords", action:"edit"}
   #      user_password PUT    /users/password(.:format)         {controller:"devise/passwords", action:"update"}
   #                    POST   /users/password(.:format)         {controller:"devise/passwords", action:"create"}

# Confirmation routes for Confirmable, if User model has :confirmable configured
# new_user_confirmation GET    /users/confirmation/new(.:format) {controller:"devise/confirmations", action:"new"}
#     user_confirmation GET    /users/confirmation(.:format)     {controller:"devise/confirmations", action:"show"}
#                       POST   /users/confirmation(.:format)     {controller:"devise/confirmations", action:"create"}