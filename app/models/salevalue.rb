class Salevalue < ApplicationRecord
	include PgSearch
	pg_search_scope :search_sales, 
	:associated_against => {
		:sale => [:id,:status,:date,:buyer]
	}

	belongs_to :user, optional: true
	belongs_to :sale, optional: true

	accepts_nested_attributes_for :user, :allow_destroy => true, reject_if: proc { |attributes| attributes['prefered_name'].blank?}

	def self.active_sv
		self.joins(:sale).where("sales.status"=>["Booked","Done"])
	end

	def self.TotalNetValue
		self.active_sv.sum(:nett_value)
	end

	def self.TotalComm
		self.active_sv.sum(:comm)
	end

	def self.TotalSPA
		self.active_sv.sum(:spa)
	end

	def self.TotalSales
		self.active_sv.count
	end

	def recalculate(unit)
		self.update(spa:unit.spa_price*self.percentage/100, nett_value:unit.nett_price*self.percentage/100, comm:unit.comm*self.percentage/100)
	end

end
