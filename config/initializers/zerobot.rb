require 'dupondius'

Dupondius.configure do |config|
  config.key_name = ENV['KEY_NAME'] || 'zerobot'
  config.cloudformation_bucket = ENV['CLOUDFORMATION_BUCKET'] || 'dupondius_cf_templates'
  config.config_bucket = ENV['CONFIG_BUCKET'] || 'dupondius_config'
  config.aws_region = ENV['AWS_REGION']
  config.access_key = ENV['AWS_ACCESS_KEY_ID']
  config.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.hosted_zone = ENV['ZONE']
  config.project_name = ENV['PROJECT_NAME']
  config.github_project = ENV['GITHUB_PROJECT']
  config.github_deploy_key = ENV['GITHUB_DEPLOY_KEY']
  config.cap_deploy_key = ENV['CAP_DEPLOY_KEY']

  # launchpad concerns
  config.github_client_id = ENV['GITHUB_CLIENT_ID']
  config.github_secret = ENV['GITHUB_SECRET']
end
