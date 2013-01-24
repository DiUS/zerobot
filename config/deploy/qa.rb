set :domain,      "qa.#{ENV['PROJECT_NAME']}.#{ENV['ZONE']}"
set :rails_env,   "qa"
set :app_env,     "qa"
set :branch,      ENV["PIPELINE_VERSION"] || 'master'

server domain, :web, :app :db, :primary => true
