class DropWebsites < ActiveRecord::Migration[5.0]
  def change
  	drop_table :websites
  end
end
