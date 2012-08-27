class Project < ActiveRecord::Base
  attr_accessible :name, :token

  validates_presence_of :name

  after_create :launch_dashboard

  def launch_dashboard
    # temporarily guard the creation of aws resources
    if Rails.configuration.aws_enabled
      Dupondius::Aws::Stacks::Dashboard.create(self.name, {KeyName: 'team-brats',
                                                           InstanceType: 'm1.small',
                                                           AwsAccessKey: Dupondius::Aws::Config.access_key,
                                                           AwsSecretAccessKey: Dupondius::Aws::Config.secret_access_key })
    end
  end

  handle_asynchronously :launch_dashboard

  def dashboard
    @dashboard ||= Dupondius::Aws::Stacks::Dashboard.find(self.name)
  end

end
