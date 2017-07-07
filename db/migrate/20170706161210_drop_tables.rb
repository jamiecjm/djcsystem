class DropTables < ActiveRecord::Migration[5.0]
  def change
  	drop_table :users
  	drop_table :sales
  	drop_table :salevalues
  	drop_table :projects
  	drop_table :units
  	drop_table :teams
  	drop_table :commissions
  end
end
