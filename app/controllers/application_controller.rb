class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_database
  before_action :must_be_approved
  
  include TeamsHelper
  include ChartsHelper
  include LocalSubdomain
  include UrlHelper

  protected

  def configure_permitted_parameters
  	update_attrs = [:password, :password_confirmation, :current_password]
    added_attrs = [:prefered_name, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: update_attrs
  end

  # set database based on subdomain
  def set_database
    web = current_website
    if web.nil?
      # redirect_to root_url(:host => domain) 
    else
      web.use_database
      session[:website_settings] = web
      session[:logo_url] = web.logo.url
    end
  end

  # def database_connected?
  #   website_subdomain == subdomain
  # end

  # Bonus - add view_path
  def set_paths
    self.prepend_view_path current_website.view_path unless current_website.view_path.blank?
  end

  # set default_url options for mailing based on subdomain
  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
    ActionMailer::Base.smtp_settings.update(user_name: ENV["#{subdomain}_email"],password: ENV["#{subdomain}_password"])
  end

  private

  def login_required
    if !signed_in?
      redirect_to new_user_session_path
    end
  end

  def admin_only
    if !current_user.admin?
      redirect_to '/'
    end
  end

  def ancestors_only
    id = params[:user_id] || params[:id]
    if !subtree_members.pluck(:id).include?(id.to_i) && !current_user.admin?
      redirect_to '/'
    end
  end

  def sales_for_ancestors_only
    if !subtree_sales.pluck(:id).include?(params[:id].to_i) && !current_user.admin?
      redirect_to '/'
    end
  end

  def leader_only
    if !leader? && !current_user.admin?
      redirect_to '/'
    end
  end

  def first_login
    if signed_in?
      if current_user.email == nil || current_user.location == nil
        flash[:info] = "Please update your profile"
        redirect_to edit_user_path(current_user) 
      end
    end
  end

  def must_be_approved
    if signed_in?
      if !current_user.approved?
        sign_out(current_user)
        flash[:info] = "Signed up successfully! You will receive an email when your account has been approved"
        redirect_to new_user_session_path 
      end
    end
  end

  def save_path
    session[:path] = request.fullpath
  end

  def redirect_to_dashboard
    redirect_to '/dashboard' if subdomain != "www"
  end
end
