module PgTools
  extend self

  def search_path
    ActiveRecord::Base.connection.schema_search_path
  end

  def default_search_path
    @default_search_path ||= %{"$user", public}
  end

  def set_search_path(name, include_public = true)
    path_parts = [name.to_s, ("public" if include_public)].compact
    ActiveRecord::Base.connection.schema_search_path = path_parts.join(",")
  end

  def restore_default_search_path
    ActiveRecord::Base.connection.schema_search_path = default_search_path
  end

  def create_schema(name)
    sql = %{CREATE SCHEMA "#{name}"}
    ActiveRecord::Base.connection.execute sql
  end

  def schemas
    sql = "SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*'"
    ActiveRecord::Base.connection.query(sql).flatten
  end

  def drop_schema(name)
    sql = %{DROP SCHEMA "#{name}" CASCADE;}
    ActiveRecord::Base.connection.execute sql
  end

  def schema_exist?(name)
    PgTools.schemas.include?(name)
  end

  # Any migration that operates on shared tables 
  # should be short-circuited if the current 
  # schema search path is private
  # class AddHostToWebsites < ActiveRecord::Migration
  #   def self.up
  #     return if PgTools.private_search_path?
  #     add_column :websites, :host, :string
  #   end

  #   def self.down
  #     return if PgTools.private_search_path?
  #     remove_column :websites, :host, :string
  #   end
  # end
  def private_search_path?
    !search_path.match /public/
  end

end