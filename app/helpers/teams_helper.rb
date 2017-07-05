module TeamsHelper

	def leader?
		Team.all.pluck(:leader_id).include?(current_user.id)
	end

  def team_sales
    if leader?
      return current_user.team.sub_tree_sales
    else
      return current_user.sub_tree_sales
    end
  end

  def subtree_sales
    if leader?
      return current_user.team.sub_tree_sales.includes({salevalues: :user},:project,:unit)
    else
      return current_user.sub_tree_sales.includes({salevalues: :user},:project,:unit)
    end
  end

  def subtree_salevalues
    if leader?
      return current_user.team.sub_tree_salevalues.includes(:sale)
    else
      return current_user.sub_tree_salevalues.includes(:sale)
    end
  end

  def subtree_members
    if leader?
      return current_user.team.sub_tree_members
    else
      return current_user.subtree
    end
  end

end
