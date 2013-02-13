require 'dupondius'

class ProjectsController < ApplicationController

  respond_to :json

  def new
    @user = GithubUser.new(session[:token]) if github_authorised?
    render :layout => false
  end

  def show
    @project = Project.find(params[:id])
    render :layout => false
  end

  def create
    params[:project][:aws_access_key] ||= Dupondius.config.access_key
    params[:project][:aws_secret_access_key] ||= Dupondius.config.secret_access_key
    params[:project][:region] ||= Dupondius.config.aws_region
    params[:project][:aws_key_name] ||= Dupondius.config.key_name

    project = Project.create!(params[:project])
    respond_with(project, :location => :projects)
  end

  private

  def github_authorised?
    !!session[:token]
  end
end
