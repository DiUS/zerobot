class Project < ActiveRecord::Base
  attr_accessible :name, :token, :tech_stack, :region,
    :github_account, :github_project, :github_private,
    :aws_access_key, :aws_secret_access_key, :aws_key_name, :url, :accept_correspondence

  validates_presence_of :name

  after_create :assign_deploy_key, :assign_github_deploy_key, :launch_dashboard

  def launch_dashboard
    instance= ec2.instances.create(image_id: 'ami-f632a4cc',
                                            key_name: self.aws_key_name,
                                            instance_type: 't1.micro',
                                            user_data: %Q{
#!/bin/bash
set -e -x

export HOME=/root
cat <<EOF >>/etc/default/app
PROJECT_NAME=#{self.name}
RAILS_ENV=production
ENABLE_LAUNCHPAD=false
AUTH_ENABLED=false
KEY_NAME=#{self.aws_key_name}
AWS_ACCESS_KEY_ID=#{self.aws_access_key}
AWS_SECRET_ACCESS_KEY=#{self.aws_secret_access_key}
AWS_REGION=#{self.region}
GITHUB_PROJECT=#{self.github_project}
GITHUB_DEPLOY_KEY=/var/local/github_deploy.pem
CAP_DEPLOY_KEY=/var/local/cap_deploy.pem
ZONE=zerobot.io
EOF

cat <<EOF >>/var/local/github_deploy.pem
#{self.github_deploy_key.private_key}
EOF


cat <<EOF >>/var/local/cap_deploy.pem
#{self.deploy_key.private_key}
EOF

cd /opt/app/zerobot/current && /usr/local/bin/bundle exec foreman export initscript /etc/init.d -e /etc/default/app -f ./Procfile.production -a zerobot -u root -l /opt/app/zerobot/shared/log

chmod +x /etc/init.d/zerobot
chkconfig zerobot on
chkconfig nginx on

/etc/init.d/nginx restart
/etc/init.d/zerobot restart

/usr/sbin/update-route53-dns --create

    })
    self.ec2_instance= instance.id
    instance.tag('zerobot:project_name', value: self.name)
    instance.tag('Name', value: self.github_project)
    save
  end

  def dashboard
    @dashboard ||= ec2.instances[self.ec2_instance]
  end

  def dashboard_url
    "http://dashboard.#{self.name}.#{Dupondius.config.hosted_zone}"
  end
  # github deploy key is used by CI to pull code
  def github_deploy_key
    SSHKey.new(read_attribute(:github_deploy_key))
  end

  # deploy key is used by the deployment process (CAP) to deploy code via ssh
  def deploy_key
    SSHKey.new(read_attribute(:deploy_key))
  end

  def show_email
    user = GithubUser.new self.token
    user.email
  end

  private

  def assign_github_deploy_key
    self.github_deploy_key= SSHKey.generate.private_key
    save!

    github_client= Octokit::Client.new(:login => self.github_account, :oauth_token => self.token)
    github_client.add_deploy_key(Octokit::Repository.from_url(self.url), 'dupondius deploy key', self.github_deploy_key.ssh_public_key)
  end

  def assign_deploy_key
    self.deploy_key= SSHKey.generate.private_key
    save!
    s3 = AWS::S3.new(
      :access_key_id     => Dupondius.config.access_key,
      :secret_access_key => Dupondius.config.secret_access_key
    )
    bucket = s3.buckets[Dupondius.config.config_bucket]
    public_key = bucket.objects["#{self.name}.pub"]
    public_key.write(self.deploy_key.ssh_public_key)
    public_key.acl= :public_read
  end

  def ec2
    @ec2 ||= AWS::EC2.new(:access_key_id => self.aws_access_key,
       :secret_access_key => self.aws_secret_access_key,
       :ec2_endpoint => "ec2.#{self.region}.amazonaws.com")
  end

end
