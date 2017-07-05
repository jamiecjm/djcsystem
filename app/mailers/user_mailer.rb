class UserMailer < ApplicationMailer

  def approve_registration(user)
    @user     = user
    subject = 'Eliteone Sales System: Approval Needed for Account Registration'
    recipients = [@user.leader,@user.leader.root]
    mail( :to      => recipients.map(&:email).uniq,
          :subject => subject) do |format|
            format.html
	  end
	end

  def notify(user)
    @user = user
    subject = "Eliteone Sales System: Account Registration Approved"
    mail( :to      => @user.email,
          :subject => subject) do |format|
            format.html
    end
  end

	def generate_report(email, sale)
	    @sale = sale
	    mail( :to      => email,
	          :subject => "Sale Report \##{@sale.id}") do |format|
	            format.html
		end
	end

  def email_admin(sale,user)
    @user = user
    @sale = sale
    recipients = ["ksadiman@iqi-group.com",@user.email]
    mail( :to      => recipients.uniq,
          :from   => @user.email,
          :reply_to => @user.email,
          :subject => "#{@sale.project.name}(Unit No: #{@sale.unit.unit_no}) [SPA and LA Signed]") do |format|
            format.html
    end
  end


end
