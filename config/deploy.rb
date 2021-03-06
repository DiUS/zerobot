load "deploy/assets"
require 'bundler/capistrano'
require 'capistrano-s3-copy'
require 'elbow/capistrano'

begin
  require 'dotenv'
  Dotenv.load
rescue LoadError
end
default_run_options[:pty] = true

# TODO: application should be set from project_name env var
set :application, 'zerobot'
set :repository,  "git@github.com:DiUS/zerobot.git"
set :user, "deployer"  # The server's user for deploys
set :scm, :git
set :git_shallow_clone, 1
set :use_sudo, false
set :applicationdir, "/opt/app/#{application}"
set :deploy_to, applicationdir
set :keep_releases, 5

set :deploy_via, :s3_copy
set :aws_access_key_id,     ENV['AWS_ACCESS_KEY_ID']
set :aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY']
set :aws_releases_bucket, 'dupondius_release'

# If you are deploying to an ELB uncomment the following line and configure accordingly
#elastic_load_balancer domain, :app, :web, :db, :primary => true

# TODO: Make the key an env var
ssh_options[:keys] = %w(zerobot-deployer.pem)

set :stages, %w(production staging qa canary)

require 'capistrano/ext/multistage'

after "deploy:setup", 'deploy:db:create'
after "deploy:update_code", "deploy:migrate"
after 'deploy:update', 'foreman:export'
after 'deploy:update', 'foreman:restart'


namespace :deploy do
  namespace :db do
    desc 'Create the database'
    task :create do
      puts "\n\n=== Creating the Database! ===\n\n"
      create_sql = <<-SQL
        CREATE DATABASE $DB_NAME;
      SQL
      run "mysql --user=$DB_USERNAME --password=$DB_PASSWORD --execute=\"#{create_sql}\""
    end

    desc 'Seed the database'
    task :seed do
      puts "\n\n=== Populating the Database! ===\n\n"
      run "cd #{release_path}; rake db:seed RAILS_ENV=#{rails_env}"
    end
  end
end

namespace :foreman do
  desc "Export the Procfile to inittab"
  task :reexport, :roles => :app do
    run init_script current_path
  end
  task :export, :roles => :app do
    run init_script release_path
  end

  desc "Start the application services"
  task :start, :roles => :app do
    sudo "/etc/init.d/#{application} start"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    sudo "/etc/init.d/#{application} stop"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    sudo "/etc/init.d/#{application} restart"
  end

  desc "Display logs for a certain process - arg example: PROCESS=web-1"
  task :logs, :roles => :app do
    run "cd #{current_path}/log && cat #{ENV["PROCESS"]}.log"
  end

  def init_script path
    ["cd #{path}",
      # Setup application environment variables
      "mkdir -p tmp/foreman",
      "echo \"RAILS_ENV=#{rails_env}\" > ./tmp/env",
      "echo \"LAUNCHPAD_ENABLED=#{ENV['LAUNCHPAD_ENABLED']}\" >> ./tmp/env",
      "echo \"AWS_ENABLED=#{ENV['AWS_ENABLED']}\" >> ./tmp/env",
      "echo \"LAUNCHPAD_JOBS=#{ENV['LAUNCHPAD_JOBS']}\" >> ./tmp/env",
      "echo \"AWS_REGION=#{ENV['AWS_REGION']}\" >> ./tmp/env",
      "echo \"DEMO_ENABLED=#{ENV['DEMO_ENABLED']}\" >> ./tmp/env",
      "echo \"AUTH_ENABLED=#{ENV['AUTH_ENABLED']}\" >> ./tmp/env",
      "echo \"OMNIAUTH_DOMAIN=#{ENV['OMNIAUTH_DOMAIN']}\" >> ./tmp/env",

      # Push the database environment variables into the app
      "cat /etc/default/app >> ./tmp/env",

      # Move it to the common place
      "sudo mv tmp/env /etc/default/#{application}",

      # Get foreman to the inittab script
      "bundle exec foreman export initscript ./tmp/foreman -e /etc/default/#{application} -f ./Procfile.production -a #{application} -u #{user} -l #{shared_path}/log",
      "sudo mv tmp/foreman/#{application} /etc/init.d",
      "chmod +x /etc/init.d/#{application}",
      "rm -rf tmp/foreman",

      # Start on boot"
      "sudo chkconfig #{application} on"
    ].join(' && ')
  end
end

