class Commission < ApplicationRecord
	belongs_to :project, optional: true
	has_many :sales
end
