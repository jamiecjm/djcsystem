module UsersHelper

	def user_subtree
		if session[:id] == nil
			current_user.subtree_members
		else
			User.find(session[:id]).subtree_members
		end
	end

end
