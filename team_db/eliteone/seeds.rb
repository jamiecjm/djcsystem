require 'csv'
ActiveRecord::Base.transaction do
  csv = CSV.new(File.open('team_db/eliteone/teams.csv'), :headers => true)
  csv.each do |row|
    team = Team.new
    row.each do |field, value|
      team.write_attribute(field.to_sym, value)
    end
    team.save(validate: false)
  end 

  csv = CSV.new(File.open('team_db/eliteone/units.csv'), :headers => true)
  csv.each do |row|
    unit = Unit.new
    row.each do |field, value|
      next if field == "sale_id"
      unit.write_attribute(field.to_sym, value)
    end
    unit.save(validate: false)
  end 

  csv = CSV.new(File.open('team_db/eliteone/salevalues.csv'), :headers => true)
  csv.each do |row|
    salevalue = Salevalue.new
    row.each do |field, value|
      if field == "ren_id"
        salevalue.write_attribute(:user_id, value)
      else
        salevalue.write_attribute(field.to_sym, value)
      end
    end
    salevalue.save(validate: false)
  end 

  csv = CSV.new(File.open('team_db/eliteone/projects.csv'), :headers => true)
  csv.each do |row|
    project = Project.new
    row.each do |field, value|
      if field == "comm_percentage"
        comm = Commission.create(effective_date: "2000-01-01",percentage: value,project_id: project.id)
      else
        project.write_attribute(field.to_sym, value)
      end
    end
    project.save(validate: false)
  end 

  csv = CSV.new(File.open('team_db/eliteone/sales.csv'), :headers => true)
  csv.each do |row|
    sale = Sale.new
    row.each do |field, value|
      if field == "unit_id"
        unit = Unit.where(id: value)
        if unit.length == 1
          sale.write_attribute(field.to_sym, value)
        else
          unit = Unit.create(unit.first.attributes.slice!("id"))
          sale.write_attribute(field.to_sym, unit.id)
        end
      else
        sale.write_attribute(field.to_sym, value)
      end
    end
    sale.save(validate: false)
    unit = sale.unit
    unit.update(comm_percentage: sale.project.commission(sale.date).percentage,sale_id: sale.id)
  end 



  csv = CSV.new(File.open('team_db/eliteone/rens.csv'), :headers => true)
  csv.each do |row|
    user = User.new
    password = 0
    row.each do |field, value|
      if field == "password_digest"
        password = value
      else
        user.write_attribute(field.to_sym, value)
      end 
    end
    user.save(validate: false)
    user.update_attribute(:encrypted_password, password)
    user.save!(validate: false)
  end
Sale.all.each {|s| s.update(commission_id: s.project.commission(s.date).id)}
User.where(team_id: nil).update(password: "eliteonesales2017")
Unit.where(sale_id: nil).destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('sales')
ActiveRecord::Base.connection.reset_pk_sequence!('units')
ActiveRecord::Base.connection.reset_pk_sequence!('users')
ActiveRecord::Base.connection.reset_pk_sequence!('teams')
ActiveRecord::Base.connection.reset_pk_sequence!('projects')
ActiveRecord::Base.connection.reset_pk_sequence!('salevalues')
end
# ActiveRecord::Base.transaction do
# csv = CSV.new(File.open('db/Eliteone Reports 2017 - Master Sales Recordv2.csv'), :headers => true)
# csv.each do |row|
#   sale=Sale.create(status: "Booked")
#   ren = [0,0,0,0]
#   sale_value = [0,0,0,0]
#   project = ""
#   unit = ""
#   row.each do |field, value|
#     next if value == nil || value == "0.00"
#     case field
#     when "Date"
#       sale.update(date: value)
#     when "Project"
#       project = Project.new(name: value.titleize)
#       if project.save 
#         sale.update(project_id: project.id)
#       else
#         project = Project.find_by(name: value.titleize)

#         sale.update(project_id: project.id)
#       end
#     when "Unit No"
#       unit=Unit.new(unit_no: value.upcase,project_id: project.id)
#       if unit.save
#         sale.update(unit_id: unit.id)
#       else
#         duplicated_unit = Unit.find_by(unit_no: value.upcase)
#         duplicated_sale = duplicated_unit.sales[0]
#         if sale.rens.pluck(:id) == duplicated_sale.rens.pluck(:id)
#           sale.destroy
#           break
#         else
#           duplicated_sale.update(status: "Canceled")
#           sale.update(unit_id: duplicated_unit.id)
#         end
#       end
#     when "Size"
#       size = value.split("+")
#       (size.length).times do |t|
#         size[t].slice!(",")
#         size[t] = size[t].to_i
#       end
#       sum = size.inject(0){|sum,x| sum + x }
#       unit.update(size: sum)
#     when "Buyer Name"
#       name =  value.split.map(&:capitalize).join(' ').rstrip
#       sale.update(buyer: name)
#     when "SPA Price"
#       value.delete!(",")
#       unit.update(spa_price: value.to_f)
#     when "Nett Price"
#       value.delete!(",")
#       unit.update(nett_price: value.to_f)
#     when "Comm %"
#       value.delete!("%")
#       project.update(comm_percentage: value.to_f)
#     when "Comm"
#       value.delete!(",")
#       unit.update(comm: value.to_f)
#     end
#     prefered_name = []
#     case
#     when ["REN 1","REN 2","REN 3","REN 4"].include?(field) == true
#       index = field.scan(/\d/)[0].to_i
#       prefered_name = value.split.map(&:capitalize).join(' ').rstrip
#       newren = User.create(prefered_name: prefered_name, approved?: false,email: Faker::Internet.email)
#       newren.update(password: 'abc')
#       newren.update(position: "Team Manager") if newren.prefered_name == "Dave Chong"
#       ren[index-1] = User.find_by(prefered_name: prefered_name)
#       sale_value[index-1] = Salevalue.create(user_id: ren[index-1].id, sale_id: sale.id)
#     when ["REN 1 %","REN 2 %","REN 3 %","REN 4 %"].include?(field) == true
#       index = field.scan(/\d/)[0].to_i
#       value.delete!("%")
#       sale_value[index-1].update(percentage: value.to_f)
#     when (field =~ /REN. Net Value/) != nil
#       value.delete!(",")
#       index = field.scan(/\d/)[0].to_i
#       sale_value[index-1].update(nett_value: value.to_f)
#     when (field =~ /REN. Comm/) != nil
#       value.delete!(",")
#       index = field.scan(/\d/)[0].to_i
#       sale_value[index-1].update(comm: value.to_f)
#     when (field =~ /REN. SPA/) != nil
#       value.delete!(",")
#       index = field.scan(/\d/)[0].to_i
#       sale_value[index-1].update(spa: value.to_f)
#   	end 

#   end
# end
# end
# ren = User.find_by(prefered_name: "Jj & Caleb")
# sv = ren.salevalues
# sale = sv[0].sale
# ren.destroy
# ren1 = User.find_by(prefered_name: "Jj Chiang")
# ren2 = User.find_by(prefered_name: "Caleb Chin")
# nett_value = sale.unit.nett_price*(12.5/100)
# spa = sale.unit.spa_price*(12.5/100)
# comm = sale.unit.comm*(12.5/100)
# Salevalue.create(percentage: 12.5, user_id: ren1.id, sale_id: sale.id,nett_value: nett_value,spa:spa,comm:comm)
# Salevalue.create(percentage: 12.5, user_id: ren2.id, sale_id: sale.id,nett_value: nett_value,spa:spa,comm:comm)

# ActiveRecord::Base.transaction do
#   leaders = User.where(name: ["Caleb Chin","Tony Yap","Wayne Lim"])
#   leaders.each {|l| l.update(position: "Team Leader")}
#   csv = CSV.new(File.open('db/Eliteone Team Structure - Sheet1.csv'), :headers => true)
#   csv.each do |row|
#     ren = []
#     row.each do |field, value|
#       next if !["REN","Referral","Team Leader"].include?(field)
#         ren = User.find_by(prefered_name: value.split.map(&:capitalize).join(' ').rstrip)
#         ren = User.new(email: Faker::Internet.email,prefered_name: value.split.map(&:capitalize).join(' ').rstrip,password: "abc",approved?: true) if ren == nil
#         ren.save(validate: false)
#     end
#   end
# end


#   csv = CSV.new(File.open('db/Eliteone Team Structure - Sheet1.csv'), :headers => true)
#   csv.each do |row|
#     ren = []
#     row.each do |field, value|
#       next if !["REN","Referral","Team Leader"].include?(field)
#       case field
#       when "REN"
#         ren = User.find_by(prefered_name: value.titleize)
#       when "Referral"
#         referral = User.find_by(prefered_name: value.titleize)
#         next if referral == ren
#         ren.update_attributes(parent: referral)
#       when "Team Leader"
#         leader = User.find_by(prefered_name: value.titleize)
#         team = Team.new(leader_id: leader.id)
#         team = Team.find_by(leader_id: leader.id) if !team.save
#         ren.update_columns(team_id: team.id)
#       end
#     end
#     ren.save
#   end

#   ren = User.find_by(prefered_name: "Athikah")
#   referral = User.find_by(prefered_name: "Hayley Tan")
#   leader = User.find_by(prefered_name: "Caleb Chin")
#   team = Team.find_by(leader_id: leader.id)
#   ren.update_attributes(parent: referral,team_id: team.id)

#   leader = User.find_by(prefered_name: "Dave Chong")
#   teams = Team.where("leader_id != ?",leader.id)
#   teams.each{|t| t.update_attributes(parent: User.find_by(prefered_name: "Dave Chong").team)}

#   User.all.each do |x|
#     ActiveRecord::Base.connection.execute("
#       UPDATE users
#       SET total_spa = (
#         SELECT SUM(spa)
#         FROM salevalues JOIN sales ON sale_id = sales.id
#         WHERE user_id = #{x.id} AND sales.status != 2
#       )
#       WHERE id = #{x.id};
#     ")
#       ActiveRecord::Base.connection.execute("
#       UPDATE users
#       SET total_nett_value = (
#         SELECT SUM(nett_value)
#         FROM salevalues JOIN sales ON sale_id = sales.id
#         WHERE user_id = #{x.id} AND sales.status != 2
#       )
#       WHERE id = #{x.id};
#     ")
#       ActiveRecord::Base.connection.execute("
#       UPDATE users
#       SET total_comm = (
#         SELECT SUM(comm)
#         FROM salevalues JOIN sales ON sale_id = sales.id
#         WHERE user_id = #{x.id} AND sales.status != 2
#       )
#       WHERE id = #{x.id};
#     ")
#       ActiveRecord::Base.connection.execute("
#         UPDATE users
#         SET total_sales = (
#           SELECT COUNT(*)
#           FROM salevalues JOIN sales ON sale_id = sales.id
#           WHERE user_id = #{x.id} AND sales.status != 2
#         )
#         WHERE id = #{x.id};
#       ")
#   end

#   Project.all.each do |project|
#     Commission.create(effective_date: "2000-01-01", percentage: project.comm_percentage)
#   end

#   User.all.update(password: "abc",approved?: true)