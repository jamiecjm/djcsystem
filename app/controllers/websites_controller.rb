class WebsitesController < ApplicationController
	# before_action :redirect_to_dashboard
	# before_action :login_required

	def index
	end
	
	def new
		@website = Website.new
	end

	def create
	end

	def edit
		@website = Website.find(params[:id])
	end

	def update
		website = Website.find(params[:id])
		website.update(website_params)
		redirect_to '/'
	end

	private

	def website_params
		params.require(:website).permit(:superteam_name, :subdomain, :logo)
	end

	
end
