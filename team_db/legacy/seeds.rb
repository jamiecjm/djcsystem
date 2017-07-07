ActiveRecord::Base.transaction do
  User.create(prefered_name: "Ashley Tan",email: "ashleytan.property@gmail.com", password:"legacy2017",approved?: true, team_id: 1)
  Team.create(leader_id: 1)
  csv = CSV.new(File.open('team_db/legacy/registration.csv'), :headers => true)
  csv.each do |row|
    user = User.new
    row.each do |field, value|
      next if value == nil
      case field.rstrip
      when "Full Name"
        user.name = value.rstrip.titleize
      when "Preferred Name"
        u = User.find_by(prefered_name: value.rstrip.titleize)
        if !u.nil?
          user = u
        end
        user.prefered_name = value.rstrip.titleize
      when "Contact No"
        user.phone_no = value
      when "Email Address"
        user.email = value
      when "Introducer"
        parent = User.find_by(prefered_name: value.rstrip.titleize)
        if parent.nil?
          parent = User.new(prefered_name: value.rstrip.titleize, password: "legacy2017", approved?: true,team_id: 1)
          parent.save(validate: false)
        end
        user.parent = parent
      when "Team Leader"
        if !user.leader?
          leader = User.find_by(prefered_name: value.rstrip.titleize)
          if leader.nil?
            leader = User.new(prefered_name: value.rstrip.titleize, password: "legacy2017", approved?: true,team_id: 1)
            leader.save(validate: false)
          end
          team = leader.team
          if !leader.leader?
            new_team = Team.create(leader_id: leader.id)
            new_team.update_attributes(parent: team)
            leader.update(team_id: new_team.id)
          end
          user.team_id = leader.team_id
        end
      end
    end
    user.password = "legacy2017"
    user.save
    user.update(approved?: true)
  end

  csv = CSV.new(File.open('team_db/legacy/sales_report.csv'), :headers => true)
  csv.each do |row|
    sale = Sale.new
    user = User.new
    salevalue = []
    project = Project.new
    unit = Unit.new
    row.each do |field, value|
      next if value == nil || value.rstrip == "-"
      case field.rstrip
      when "Timestamp"
        sale.date = value.gsub(/(\d+).(\d+).(\d+).+/, '\2/\1/\3')
      when "PROJECT NAME"
        if Project.find_by_name(value.rstrip.titleize)
          project = Project.find_by_name(value.rstrip.titleize)
        else
          project.name = value.rstrip.titleize
          project.save
        end
        sale.project_id = project.id
      when "CUSTOMER NAME"
        sale.buyer = value.rstrip.titleize
      when "SPA PRICE (in figure only without *rm)"
        unit.spa_price = value.rstrip
      when "NETT PRICE (in figure only without *rm)"
        unit.nett_price = value.rstrip
      when "PACKAGE (discount + rebate in %)"
        sale.package = value.rstrip
      when "Commission (in %)"
        next if value.to_i > 100
        comm = project.commission(sale.date)
        if comm.nil?
          comm = Commission.create(project_id:project.id,percentage: value.rstrip.delete("%"),effective_date: "2000-1-1")
        end
        sale.commission_id = comm.id
        unit.comm_percentage = comm.percentage
        unit.comm = unit.comm_percentage/100*unit.nett_price*0.94
        unit.project_id = project.id
        unit.sale_id = sale.id
      end
      case
      when field.rstrip =~ /(REN .: Name)/
        user = User.find_by(prefered_name: value.rstrip.titleize)
        if user.nil?
          user = User.new(prefered_name: value.rstrip.titleize, password: "legacy2017")
          user.save(validate: false)
        end
      when field.rstrip =~ /(REN .: %)/
        sv = Salevalue.new(percentage: value.rstrip.delete("%"),user_id: user.id, sale_id: sale.id)
        sv.save
        salevalue << sv
      end
    end
    unit.save(validate: false)
    sale.unit_id = unit.id
    sale.save skip_callback: true
    salevalue.each do |sv|
      sv.recalculate(unit)
      sv.update(sale_id: sale.id)
    end
  end
end
