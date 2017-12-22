class UsersController < ApplicationController


	skip_before_action :verify_authenticity_token, only: :approve
	before_action :login_required, except: [:new,:create]
	before_action :first_login, except: [:edit,:update,:change_user,:revert_user]
	before_action :ancestors_only, only: [:sales,:edit,:update]
	before_action :save_path, only: [:index,:new,:sales,:edit,:requests]
	before_action :set_mailer_host, only: [:approve]

	def index
		@users = User.approved.order("prefered_name").page params[:page]
	end

	def new
		@user = User.new
		@title = "Register new account"
	end

	def create
		user = User.new(user_signup_params)
		if user.save
			UserMailer.approve_registration(user, website_name).deliver
			flash[:success] = "Successfully registered. You will receive an confirmation email when your request has been approved."
			redirect_to root_path
		else
			flash.now[:danger] = user.errors.full_messages.first
			render "new"
		end
	end

	def sales
		range = set_date_range(params[:month],params[:date1],params[:date2])
		@from = range["from"]
		@to = range["to"]
		@user = User.find(params[:user_id])
		@sales = @user.salevalues.joins(:sale).where("sales.date >= :from AND sales.date <= :to",{from: @from,to: @to})
		@salevalues = @user.salevalues.joins(:sale).where("sales.date >= :from AND sales.date <= :to",{from: @from,to: @to}).includes(sale:[:project,:unit]).order("sales.date DESC, sales.id DESC").page(params[:page]).per(params[:limit])
		@spa = @sales.where("sales.status != ?", 2).sum(:spa)
		@nett_value = @sales.where("sales.status != ?", 2).sum(:nett_value)
		@comm = @sales.where("sales.status != ?", 2).sum(:comm)
		@total = @sales.where("sales.status != ?", 2).count
		@title = "#{@user.prefered_name}'s sales"
	end

	def edit
		@user = User.find(params[:id])
		@title = "Edit profile"

	end

	def update
		@user = User.find(params[:id])
		if @user.update(update_params)
			flash[:success] = "Profile updated"
			redirect_to session[:path]
		else
			flash.now[:danger] = @user.errors.full_messages.first
			render 'edit'
		end
	end

	def requests
		@users = current_user.team.sub_tree_members.where(approved?: false).where.not(team_id: nil)
		@title = "New members"
	end

	def approve
		if params[:status] == 'true'
			users = User.where('id' => params[:tag_ids])
			users.update_all(approved?: true)
			users.each do |user|
				UserMailer.notify(user,website_name).deliver
			end
			flash[:success] = "Account approved"
		else
			User.where('id' => params[:tag_ids]).destroy_all
			flash[:info] = "Request deleted"
		end
		redirect_to '/requests'
	end

	def destroy
		user = User.find(params[:id])
		user.destroy
		flash[:info] = "User deleted"
		redirect_to '/'
	end

	def change_user
		if params[:user].nil?
			redirect_to "/revert_user"
		else
			session[:id] = current_user.id if session[:id] == nil
			sign_in(User.find(params[:user]))
			redirect_to session[:path]
		end
	end

	def revert_user
		if session[:id] != nil
			sign_in(User.find(session[:id]))
			session[:id] = nil
		end
		redirect_to '/'
	end

	private

	def user_signup_params
	    params.require(:user).permit(:name,:email,:prefered_name,:phone_no,:birthday,:location,:password,:password_confirmation,:parent_id)
	end

	def update_params
		params.require(:user).permit(:name,:email,:prefered_name,:phone_no,:birthday,:location,:parent_id)
	end



end