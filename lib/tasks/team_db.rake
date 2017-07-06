task spec: ["team:db:test:prepare"]
task :all => ["eliteone:db:drop", "legacy:db:drop"]

namespace :team do
 
  namespace :db do |ns|
 

    task :drop do
      Rake::Task['eliteone:db:drop'].invoke && Rake::Task['legacy:db:drop'].invoke
    end
 
    task :create do
      Rake::Task["db:create"].invoke
    end
 
    task :setup do
      Rake::Task["db:setup"].invoke
    end
 
    task :migrate do
      Rake::Task["db:migrate"].invoke
    end
 
    task :rollback do
      Rake::Task["db:rollback"].invoke
    end
 
    task :seed do
      Rake::Task["db:seed"].invoke
    end
 
    task :version do
      Rake::Task["db:version"].invoke
    end
 
    namespace :schema do
      task :load do
        Rake::Task["db:schema:load"].invoke
      end
 
      task :dump do
        Rake::Task["db:schema:dump"].invoke
      end
    end
 
    namespace :test do
      task :prepare do
        Rake::Task["db:test:prepare"].invoke
      end
    end
 
    # append and prepend proper tasks to all the tasks defined here above
    ns.tasks.each do |task|
      task.enhance ["eliteone:set_custom_config"] do
        Rake::Task["eliteone:revert_to_original_config"].invoke
      end
    end
  end
 
end