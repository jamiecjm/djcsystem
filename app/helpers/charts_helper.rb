module ChartsHelper

  def month(year)
  	today = Date.today
  	y = year.to_i
  	(["Up to Date","December #{y-1}"]<<(1..12).to_a.map {|n| Date::MONTHNAMES[n]+" #{y}"}).flatten
  end

  def set_date_range(m,date1,date2)
  	today = Date.today
  	year = today.year
  	range = {}
	if m == "Up to Date"
		if today < Date.civil(year,12,16)
			y = year-1
		else
			y = year	
		end	
		range["to"] = today
		range["from"] = Date.civil(y, 12, 16)	
	elsif !m.blank?
		selected_month = Date::MONTHNAMES.index(m.split(" ")[0])
		y = m.split(" ")[1].to_i
		if selected_month == 12 && y == year-1
			range["from"] = Date.civil(y, 12, 16)
			range["to"] = Date.civil(y, 12, -1)
		elsif selected_month == 12 && y == year
			range["from"] = Date.civil(y, 12, 1)
			range["to"] = Date.civil(y, 12, 15)	
		else
			range["from"] = Date.civil(y, selected_month, 1)
			range["to"] = Date.civil(y, selected_month, -1)			
		end
	elsif date1.blank? || date2.blank?
		this_month = Date.today.month
		if this_month == 12
			if today.day < 16
				range["from"] = Time.parse(today.to_s).strftime("%Y-%m-01")
			else
				range["from"] = Time.parse(today.to_s).strftime("%Y-%m-16")
			end
		else
			range["from"] = Time.parse(today.to_s).strftime("%Y-%m-01")
		end
		range["to"] = today
	else
		range["from"] = date1
		range["to"] = date2
	end
	return range
  end

end
