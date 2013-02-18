
class Aws::TemplatesController < ApplicationController

  respond_to :json

  def index
    template = Dupondius::Aws::CloudFormation::Template.all.reject! do |templ| 
      ['dashboard-ami.template', 'jenkins-ruby-on-rails.template'].include? templ[:id]
    end
    respond_with(template)
  end

  def show
    template = Dupondius::Aws::CloudFormation::Stack.validate_template(params[:id])
    template[:parameters].reject! do |p|
      ['ProjectName', 'HostedZone', 'AwsAccessKey', 'AwsSecretAccessKey', 'KeyName'].include? p[:parameter_key]
    end
    respond_with(template)
  end
end
