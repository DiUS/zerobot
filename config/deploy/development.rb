set :domain,      "dev.#{ENV['PROJECT_NAME']}.zerobot.io"
set :rails_env,   "development"
set :app_env,     "development"
set :branch,      ENV["PIPELINE_VERSION"] || 'master'

server domain, :web, :app :db, :primary => true
