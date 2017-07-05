class MainsController < ApplicationController
	before_action :redirect_to_dashboard

	def index
	end

	private

	def redirect_to_dashboard
		redirect_to '/dashboard' if !request.subdomain.blank?
	end
end

