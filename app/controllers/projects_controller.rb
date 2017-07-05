class ProjectsController < ApplicationController
	
	before_action :login_required
	before_action :first_login
	before_action :leader_only
	before_action :save_path, only: [:new,:index,:edit]


	def new
		@project = Project.new
		@title = "New Project"
	end

	def create
		@project = Project.new(project_params)
		if @project.save
			flash[:success] = "Project created"
			redirect_to projects_path
		else
			flash.now[:danger] = @project.errors.full_messages.first
			render "new"
		end
	end

	def index
		@projects = Project.all.includes(:commissions).page params[:page]
		@title = "Projects"
	end

	def edit
		@project = Project.find(params[:id])
		@title = "Edit project"
	end

	def update
		@project = Project.find(params[:id])
		if @project.update(project_params)
			comms = @project.commissions.select {|comm| comm.updated_at.to_date == Date.today }
			if comms != []
				@project.sales.each do |sale|
					sale.set_commission_id
					sale.save(validate: false)
					sale.calculate
				end
			end
			flash[:success] = "Project updated"
			redirect_to projects_path
		else
			flash.now[:danger] = @project.errors.full_messages.first
			render "edit"
		end
	end

	def destroy
		project = Project.find(params[:id])
		project.destroy
		flash[:info] = "Project deleted"
		redirect_to projects_path
	end

	private

	def project_params
		params.require(:project).permit(:name,commissions_attributes: [:id,:percentage,:effective_date,:_destroy])
	end
end
# Project.first.sales.each do |x|
# 	ActiveRecord::Base.connection.execute("UPDATE sales SET commission_id = (SELECT commissions.id FROM sales JOIN projects ON sales.project_id = projects.id JOIN commissions ON commissions.project_id = projects.id WHERE commissions.effective_date <= #{x.date} ORDER BY commissions.effective_date DESC LIMIT 1) WHERE id = #{x.id};")
# Project.first.sales.each do |x|
# 	ActiveRecord::Base.connection.execute("UPDATE units SET comm = ( SELECT commissions.percentage/100*units.nett_price*0.94 FROM commissions JOIN sales ON commission_id = commissions.id JOIN units ON sales.id = sale_id WHERE sales.id = #{x.id}) WHERE id = #{x.unit_id};")
# end
# Project.first.sales.each do |x|
# 	ActiveRecord::Base.connection.execute("UPDATE units SET comm_percentage = ( SELECT commissions.percentage FROM commissions JOIN sales ON commission_id = commissions.id JOIN units ON sales.id = sale_id WHERE sales.id = #{x.id}) WHERE id = #{x.unit_id};")
# end
		# comm = self.commission
		# unit = self.unit
		# unit.update(sale_id: self.id,project_id: self.project_id,comm: comm.percentage/100*unit.nett_price*0.94,comm_percentage: comm.percentage)
		# self.salevalues.each do |sv|
		# 	sv.recalculate(unit)
		# 	sv.user.recalculate
		# end	

# end