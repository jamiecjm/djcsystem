class Team < ApplicationRecord
	has_many :users
	belongs_to :leader, optional: true, :class_name => "User"
	has_ancestry
	validates :leader_id, uniqueness: :true

  def sub_tree_sales
    Sale.joins(:users).where("users.team_id" => self.subtree).distinct
  end

  def sub_tree_salevalues
    Salevalue.joins(:user).where("users.team_id" => self.subtree)
  end

  def sub_tree_members
    User.where(team_id: self.subtree.pluck(:id))
  end
end
