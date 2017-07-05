class SearchesController < ApplicationController

	before_action :login_required
	before_action :first_login
	
	def search_by_name
		@paginated_user = User.search_by_name(params[:search]).where('id' => params[:ids]).includes(team:[:leader]).page params[:page]
		respond_to do |format|
			format.js
		end
	end

	def search_team_sales
		case params[:search].downcase
		when 'booked'
			params[:search] = 0
		when 'done'
			params[:search] = 1
		when 'canceled'
			params[:search] = 2
		end
		@sales = Sale.search_sales(params[:search]).where('id' => params[:ids]).page params[:page]
		respond_to do |format|
			format.js
		end
	end

	def search_individual_sales
		case params[:search].downcase
		when 'booked'
			params[:search] = 0
		when 'done'
			params[:search] = 1
		when 'canceled'
			params[:search] = 2
		end
		@salevalues = Salevalue.search_sales(params[:search]).page params[:page]
		respond_to do |format|
			format.js
		end
	end
end
