require 'dupondius'

class ProjectsController < ApplicationController

  respond_to :json

  def new
    @user = GithubUser.new(session[:token]) if github_authorised?
    render :layout => false
  end

  def show
    if Rails.configuration.demo_enabled
      status = 'NOT_COMPLETE'
      status = 'CREATE_COMPLETE' if Random.rand < 0.4

      render :json => {
        :id => 1,
        :name => 'YOWDemo',
        :output => { :key => 1, :value => "http://dashboard.yowdemo.zerobot.io" },
        :status => status
      }
    else
      @project = Project.find(params[:id])
      render :layout => false
    end
  end

  def create
    if Rails.configuration.demo_enabled
      render :json => {
        :id => 1,
        :name => 'YOWDemo'
      }
    else
      github_private = params[:project][:github_private] ? true : false
      project = Project.create!(params[:project].except(:support, :github_private).merge(:github_private => github_private))
      respond_with(project, :location => :projects)
    end
  end

  private

  def github_authorised?
    !!session[:token]
  end
end
