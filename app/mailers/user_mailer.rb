class UserMailer < ApplicationMailer

  def approve_registration(user,website_name)
    @user     = user
    @team_name = website_name
    subject = "DJC Sales System: Approval Needed for Account Registration"
    recipients = [@user.leader,@user.leader.root]
    mail( :to      => recipients.map(&:email).uniq,
          :subject => subject) do |format|
            format.html
	  end
	end

  def notify(user)
    @user = user
    subject = "DJC Sales System: Account Registration Approved"
    mail( :to      => @user.email,
          :subject => subject) do |format|
            format.html
    end
  end

	def generate_report(email, sale, website_name)
	    @sale = sale
      @team_name = website_name
	    mail( :to      => email,
	          :subject => "Sale Report \##{@sale.id}") do |format|
	            format.html
		end
	end

  def email_admin(sale,user,website_name)
    @user = user
    @sale = sale
    @team_name = website_name
    recipients = ["ksadiman@iqi-group.com",@user.email]
    mail( :to      => recipients.uniq,
          :from   => @user.email,
          :reply_to => @user.email,
          :subject => "#{@sale.project.name}(Unit No: #{@sale.unit.unit_no}) [SPA and LA Signed]") do |format|
            format.html
    end
  end


end
