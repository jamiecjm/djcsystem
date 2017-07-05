class Website < ApplicationRecord

	mount_uploader :logo, LogoUploader

	def use_database
		if self.subdomain == "www"
			Website.revert_database
		else
	  		ActiveRecord::Base.establish_connection(self.database)
	  	end
	end

	# Revert back to the shared database
	def self.revert_database
	  ActiveRecord::Base.establish_connection(@default_config)
	end

	def database
		YAML::load(ERB.new(File.read(Rails.root.join("config","#{self.subdomain}_db.yml"))).result)[Rails.env]
	end

	def self.db(team)
	  YAML::load(ERB.new(File.read(Rails.root.join("config","#{team}_db.yml"))).result)[Rails.env]
	end

 	def self.connect_db(team)
	  ActiveRecord::Base.establish_connection(self.db(team))
	end

end
