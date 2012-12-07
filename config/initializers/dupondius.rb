require 'dupondius'

Dupondius.configure do |config|
  config.key_name = ENV['KEY_NAME'] || 'zerobot'
  config.cloudformation_bucket = 'dupondius_cf_templates'
  config.config_bucket = 'dupondius_config'
  config.aws_region = ENV['AWS_REGION']
  config.access_key = ENV['AWS_ACCESS_KEY_ID']
  config.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.hosted_zone = ENV['ZONE']
  config.project_name = ENV['PROJECT_NAME']
  config.github_client_id = ENV['GITHUB_CLIENT_ID']
  config.github_secret = ENV['GITHUB_SECRET']
end
