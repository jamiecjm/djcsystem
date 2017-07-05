class Project < ApplicationRecord
	has_many :sales
	has_many :units
	has_many :commissions, dependent: :destroy

	validates :name, uniqueness:{ message: "already existed"}

	before_validation :titleize

	accepts_nested_attributes_for :commissions, :allow_destroy => true

	def commission(date)
		self.commissions.where('effective_date <= ?', date).order("effective_date DESC").first
	end

	private
	
	def titleize
		self.name = self.name.titleize
	end


end
