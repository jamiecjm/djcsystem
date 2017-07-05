class ChartsController < ApplicationController

	before_action :login_required
	before_action :first_login
	before_action :save_path

	def uptodate_barchart
		@ren = subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2).order("SUM(salevalues.nett_value) DESC").pluck(:prefered_name)
		@ren.inspect.gsub(/"/, '\"')
		@value = subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2).order("sum(salevalues.nett_value) DESC").sum("salevalues.nett_value").values
		@value.inspect.gsub(/"/, '\"')
	    if @ren.length < 40
	      @height= 40*20
	    else
	      @height = @ren.length*20
	    end
	    @font = 12
	end

	def monthly_barchart
		@months = month[1..month.length-1]
		range = set_date_range(params[:month],params[:date1],params[:date2],true)
		@from = range["from"]
		@to = range["to"]
		# if params[:location].blank?
		# 	@location = "All Locations"
		# 	@members=subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2)
		# 	byebug
		# else
		# 	@location = User.locations.select{|key,value| value == params[:location].to_i}.keys.first
		# 	@members=subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2).where(location: params[:location].to_i)
		# end
		@monthly_sales = subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").where("sales.status != ?", 2).where("sales.date >= ?",@from).where("sales.date <= ?",@to).group("DATE_TRUNC('month', sales.date)").sum("salevalues.nett_value")
		@months.each do |m| 
			@monthly_sales[m.to_date] = 0 if !@monthly_sales.keys.map(&:to_date).include?(m.to_date)
		end
		@nett_value = @monthly_sales.sort.to_h.values
	end

	def barchart
		@title = "Sales Chart"
		range = set_date_range(params[:month],params[:date1],params[:date2],false)
		@from = range["from"]
		@to = range["to"]
		if params[:location].blank?
			@location = "All Locations"
			@members=subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2).where("sales.date >= ?",@from).where("sales.date <= ?",@to).order("SUM(salevalues.nett_value) DESC")
		else
			@location = User.locations.select{|key,value| value == params[:location].to_i}.keys.first
			@members=subtree_members.joins(:salevalues).joins("LEFT JOIN sales ON sale_id = sales.id").group(:id).where("sales.status != ?", 2).where("sales.date >= ?",@from).where("sales.date <= ?",@to).where(location: params[:location].to_i).order("SUM(salevalues.nett_value) DESC")
		end
		@ren = @members.pluck(:prefered_name)
		@value = @members.sum("salevalues.nett_value").values
		@ren.inspect.gsub(/"/, '\"')
		@value.inspect.gsub(/"/, '\"')
		@min_data = 40
	    if @ren.length < @min_data
	      @height= @min_data*20
	    else
	      @height = @ren.length*20
	    end
	    @font = 12
	end
end
