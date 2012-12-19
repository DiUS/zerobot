require 'dupondius'

class ProjectsController < ApplicationController

  respond_to :json

  def new
    if session[:token]
      render :layout => false
    else
      redirect_to :action => 'authorise'
    end
  end

  def show
    if Rails.configuration.demo_enabled
      @project = Project.find(params[:id])
      render :json => {
        :id => @project.id,
        :name => @project.name,
        :output => { :key => 1, :value => "http://dashboard.#{@project.name}.zerobot.io" },
        :status => 'CREATE_COMPLETE'
      }
    else
      @project = Project.find(params[:id])
      render :layout => false
    end
  end

  def create
    if Rails.configuration.demo_enabled
      Project.skip_callback(:create, :after, :assign_deploy_key, :assign_github_deploy_key, :launch_dashboard, :launch_ci)
      project = Project.create(:name => params[:project][:name])

      render :json => {
        :id => project.id,
        :name => project.name
      }
    else
      github_private = params[:project][:github_private] ? true : false
      project = Project.create!(params[:project].except(:support, :github_private).merge(:github_private => github_private))
      respond_with(project, :location => :projects)
    end
  end

end
