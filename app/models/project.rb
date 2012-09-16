class Project < ActiveRecord::Base
  attr_accessible :name, :token, :tech_stack, :region

  validates_presence_of :name

  after_create :launch_dashboard

  def launch_dashboard
    # temporarily guard the creation of aws resources
    if Rails.configuration.aws_enabled
      Dupondius::Aws::CloudFormation::Dashboard.new(self.name, self.tech_stack, self.region,  {
          InstanceType: 'm1.small',
          DBName: 'dashboard',
          DBUsername: 'dashboard',
          DBPassword: 'dashboard',
          DBRootPassword: 'r00tr00t'
      }).create
    end
  end

  handle_asynchronously :launch_dashboard

  def dashboard
    @dashboard ||= Dupondius::Aws::CloudFormation::Dashboard.find(self.name, self.region)
  end

end
