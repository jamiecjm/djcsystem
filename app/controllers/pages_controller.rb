class PagesController < ApplicationController

	before_action :login_required
	before_action :first_login
	before_action :admin_only, except: [:index,:dashboard]
	before_action :save_path

	def index
		redirect_to "/users/#{current_user.id}/sales"
	end

	def sales
		@sales = Sale.where.not('id' => User.find_by(prefered_name: "Dave Chong").team.sub_tree_sales.pluck(:id).uniq).includes({salevalues: :user},:project,:unit).page params[:page]
		@maxren = Sale.joins(:salevalues).where("sales.id"=>subtree_sales).select("sales.*,count(salevalues.id) as scount").group("sales.id").order("scount DESC").limit(1)[0].users.count
		@title = "Other sales"
	end

	def users
		@users = User.where(team_id: nil).includes(:sales).order("prefered_name").page params[:page]
		@title = "Other users"
	end

	def units
		@units = Unit.where(sale_id: nil).includes(:project).page params[:page]
		@title = "Other units"
	end

	def dashboard
		@title = "Dashboard"
		# individual summary
		@individual_from = "2016-12-16"
		@individual_to = Date.today
		@individual_sales = current_user.salevalues.joins(:sale).where("sales.date >= :from AND sales.date <= :to",{from: @individual_from,to: @individual_to})
		@individual_spa = @individual_sales.where("sales.status != ?", 2).sum(:spa)
		@individual_nett_value = @individual_sales.where("sales.status != ?", 2).sum(:nett_value)
		@individual_comm = @individual_sales.where("sales.status != ?", 2).sum(:comm)
		@individual_total = @individual_sales.where("sales.status != ?", 2).count
		# 
		# team summary
		@team_from = "2016-12-16"
		@team_to = Date.today
		@members=subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2).where("sales.date >= ?",@team_from).where("sales.date <= ?",@team_to)
		@team_spa = @members.sum("salevalues.spa").values.sum
		@team_nett_value = @members.sum("salevalues.nett_value").values.sum
		@team_comm = @members.sum("salevalues.comm").values.sum
		@team_total = subtree_sales.where("sales.status != ?", 2).where("sales.date >= ?","2016-12-16").where("sales.date <= ?",Date.today).count
		# 
		# team sales chart
		@from = Time.parse(Date.today.to_s).strftime("%Y-%m-01")
		@to = Date.today
		@members=subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2).where("sales.date >= ?",@from).where("sales.date <= ?",@to).order("SUM(salevalues.nett_value) DESC")
		@ren = @members.pluck(:prefered_name)
		@value = @members.sum("salevalues.nett_value").values
		@ren.inspect.gsub(/"/, '\"')
		@value.inspect.gsub(/"/, '\"')
		@min_data = 20
	    if @ren.length < @min_data
	      @height= @min_data*20
	    else
	      @height = @ren.length*20
	    end
	    @font = 12
		# 
	end

end
