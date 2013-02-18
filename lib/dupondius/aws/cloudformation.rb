
module Dupondius; module Aws; module CloudFormation

  ENVIRONMENTS = [:ci, :dev, :canary, :qa, :performance, :production]

  REGIONS = {
     'us-east-1' =>  {name: 'US East (Virginia)', endpoint: 'cloudformation.us-east-1.amazonaws.com'},
     'us-west-1' => {name: 'US West (North California)', endpoint: 'cloudformation.us-west-1.amazonaws.com'},
     'us-west-2' => {name: 'US West (Oregon)', endpoint: 'cloudformation.us-west-2.amazonaws.com'},
     'eu-west-1' => {name: 'EU West (Ireland)', endpoint:  'cloudformation.eu-west-1.amazonaws.com'},
     'ap-southeast-1' => {name: 'Asia Pacific (Singapore)', endpoint: 'cloudformation.ap-southeast-1.amazonaws.com'},
     'ap-southeast-2' => {name: 'Asia Pacific (Sydney)', endpoint: 'cloudformation.ap-southeast-2.amazonaws.com'},
     'ap-northeast-1' => {name: 'Asia Pacific (Tokyo)', endpoint: 'cloudformation.ap-northeast-1.amazonaws.com'},
     'sa-east-1' => {name: 'South Amercia (Sao Paulo)', endpoint: 'cloudformation.sa-east-1.amazonaws.com'}
  }

  def self.access(region = Dupondius.config.aws_region)
    AWS::CloudFormation.new(:access_key_id => Dupondius.config.access_key,
       :secret_access_key => Dupondius.config.secret_access_key,
       :cloud_formation_endpoint => REGIONS[region][:endpoint])
  end

  def self.summaries project_name= Dupondius.config.project_name, status = :create_complete
    Dupondius::Aws::CloudFormation.access.stack_summaries.select do |s|
      s if s[:stack_name] =~ /.*#{project_name}$/
    end
  end

  class Template

    def self.all
      bucket.objects.collect do |template|
        {id: template.key, name: File.basename(template.key, File.extname(template.key)).humanize}
      end
    end

    def self.find(key)
      bucket.objects[key].read
    end

    private
    def self.bucket
      s3.buckets[Dupondius.config.cloudformation_bucket]
    end
    def self.s3
      @s3 ||= AWS::S3.new(
        :access_key_id     => Dupondius.config.access_key,
        :secret_access_key => Dupondius.config.secret_access_key
      )
    end
  end

  class Stack

    def initialize subject
      @subject = subject
    end

    def method_missing(sym, *args, &block)
      @subject.send sym, *args, &block
    end

    def self.find stack_name
      stack = Dupondius::Aws::CloudFormation.access.stacks[stack_name]
      stack.exists? ? self.new(stack) : nil
    end

    def self.create template_name, environment_name, project_name, parameters
      self.new(Dupondius::Aws::CloudFormation.access.stacks.create("#{environment_name}-#{project_name}", Template.find(template_name),
        :disable_rollback => true,
        :parameters => {HostedZone: Dupondius.config.hosted_zone,
                        ProjectName: project_name,
                        AwsAccessKey: Dupondius.config.access_key,
                        AwsSecretAccessKey: Dupondius.config.secret_access_key,
                        KeyName: Dupondius.config.key_name}.merge(parameters)))
    end

    def self.validate_template template_name
      Dupondius::Aws::CloudFormation.access.validate_template(Template.find(template_name))
    end

    def self.template_params template_name
      params = Dupondius::Aws::CloudFormation.access.validate_template(Template.find(template_name))[:parameters].collect do |p|
        p[:parameter_key]
      end
    end

    def template_name
      self.description.match(/\w+\.\w+$/).to_s
    end

    def update params
      super({template: Template.find(template_name), parameters: self.parameters.merge(params)})
    end

    def complete?
      @subject.status == 'CREATE_COMPLETE'
    end

    def as_json options={}
      result = {}
      AWS.memoize do
        result = [:name, :description, :status, :creation_time, :last_updated_time,
         :description, :parameters, :template_name].inject({}) do |result, attribute|
            result[attribute] = self.send(attribute)
            result
        end
        result[:parameters].reject! do |p, v|
          ['ProjectName', 'HostedZone', 'AwsAccessKey', 'AwsSecretAccessKey', 'KeyName'].include? p
        end
        result[:resource_summaries] = self.resource_summaries.collect do |r|
          resource = [:resource_type, :logical_resource_id].inject({}) do |h, a|
            h[a] = r[a]
            h
          end
          if r[:resource_type] == 'AWS::EC2::Instance'
            resource[:status] = :running
          end
          resource
        end
      end
      result
    end
  end

end; end; end
