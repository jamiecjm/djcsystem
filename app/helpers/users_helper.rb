module UsersHelper

	def user_subtree
		if session[:id] == nil
			current_user.subtree
		else
			User.find(session[:id]).subtree
		end
	end

end
