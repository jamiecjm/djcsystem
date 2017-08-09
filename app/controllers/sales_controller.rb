class SalesController < ApplicationController


	skip_before_action :verify_authenticity_token, only: :change_status
	before_action :login_required
	before_action :first_login
	before_action :sales_for_ancestors_only, only: [:edit, :update, :destroy]
	before_action :save_path,only: [:new,:edit]
	before_action :set_mailer_host, only: [:create]

	def new
		@sale = Sale.new
		@title = "New sale"
	end

	def create
		@sale = Sale.new(new_sale_params)
		if @sale.save
			UserMailer.generate_report(current_user.email, @sale, website_name).deliver
			flash[:success] = "Sale record created"	
			redirect_to "/"
		else
			flash.now[:danger] = @sale.errors.full_messages.first
			render 'new'
		end
	end

	def edit
		@sale = Sale.find(params[:id])
		@title = "Edit sale \##{params[:id]}"
	end

	def update
		@sale = Sale.find(params[:id])
		if @sale.update(new_sale_params)
			@sale.after_save_action
			flash[:success] = "Sale record updated"	
			redirect_to "/sales/#{@sale.id}/edit"
		else
			flash.now[:danger] = @sale.errors.full_messages.first
			render 'edit'
		end
	end

	def change_status
		@sales = Sale.where('id' => params[:tag_ids]).includes(salevalues: [:user])
		@sales.update_all(status: params[:status])
		redirect_to session[:path]
	end

	def destroy
		@sale = Sale.find(params[:id])
		@sale.destroy
		flash[:info] = "Sale \##{@sale.id} deleted"
		redirect_to '/'
	end

	def email
		@sale = Sale.find(params[:sale])
		if @sale.spa_sign_date == nil
			flash.now[:danger] = "SPA Sign Date must not be empty. Make sure you have updated the sale record."
			render "edit"
		else
			@sale.update(status: "Done")
			UserMailer.email_admin(@sale,current_user,website_name).deliver
			flash[:success] = "Email has been delivered"
			redirect_to "/sales/#{@sale.id}/edit"
		end
	end

	private
	def new_sale_params
		params.require(:sale).permit(:date,:project_id,:buyer,:package,:remark,:status,:unit_id,:spa_sign_date,:la_date,
			salevalues_attributes: [:id,:user_id,:percentage,:_destroy],
			salevalues2_attributes:[:id,:user_id,:percentage,:_destroy,
			user_attributes: [:id,:prefered_name,:password,:approved?,:_destroy]],
			unit_attributes: [:id,:sale_id,:unit_no,:size,:spa_price,:nett_price,:_destroy])
	end


end
