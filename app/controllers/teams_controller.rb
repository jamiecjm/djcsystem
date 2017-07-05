class TeamsController < ApplicationController

	before_action :login_required
	before_action :first_login
	before_action :save_path, only: [:sales,:members,:profiles]

	def sales
		range = set_date_range(params[:month],params[:date1],params[:date2],true)
		@from = range["from"]
		@to = range["to"]
		@sales = subtree_sales.where("sales.date >= ?",@from).where("sales.date <= ?",@to).order(date: :desc, id: :desc).distinct.page(params[:page]).per(params[:limit])
		@members=subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2).where("sales.date >= ?",@from).where("sales.date <= ?",@to).order("SUM(salevalues.nett_value) DESC")
		@spa = @members.sum("salevalues.spa").values.sum
		@nett_value = @members.sum("salevalues.nett_value").values.sum
		@comm = @members.sum("salevalues.comm").values.sum
		@total = subtree_sales.where("sales.status != ?", 2).where("sales.date >= ?",@from).where("sales.date <= ?",@to).count
		if @sales != []
			@maxren = Sale.joins(:salevalues).where("sales.id"=>subtree_sales).where("sales.date >= ?",@from).where("sales.date <= ?",@to).select("sales.*,count(salevalues.id) as scount").group("sales.id").order("scount DESC").limit(1)[0].users.count
		else
			@maxren = 1
		end
		@title = "Team sales"
	end

	def members
		range = set_date_range(params[:month],params[:date1],params[:date2],false)
		@from = range["from"]
		@to = range["to"]
		if params[:location].blank? || params[:location] == nil
			@location = "All"
			@members=subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2).where("sales.date >= ?",@from).where("sales.date <= ?",@to).order("SUM(salevalues.nett_value) DESC")
			@sales = subtree_sales.where("sales.status != ?", 2).where("sales.date >= ?",@from).where("sales.date <= ?",@to).count
		else
			@location = User.locations.select{|key,value| value == params[:location].to_i}.keys.first
			@sales = subtree_sales.where("sales.status != ?", 2).where("sales.date >= ?",@from).where("sales.date <= ?",@to).where('users.location = ?', params[:location].to_i).count
			@members=subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2).where("sales.date >= ?",@from).where("sales.date <= ?",@to).where(location: params[:location].to_i).order("SUM(salevalues.nett_value) DESC")
		end
		@user = @members.page(params[:page]).per(params[:limit])
		@spa = @members.sum("salevalues.spa").values
		@nett_value = @members.sum("salevalues.nett_value").values
		@comm = @members.sum("salevalues.comm").values
		@total = @members.count("salevalues.*").values
		@title = "Team sales summary"
	end

	def profiles
		@users = subtree_members.approved.order('created_at DESC').includes(team:[:leader])
		@paginated_user = @users.page(params[:page]).per(params[:limit])
		@title = "Team member profiles"
	end
	
end
