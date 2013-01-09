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
      status = 'CREATE_COMPLETE' if Random.rand < 0.6

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
      check = AWS::EC2.new(
          :access_key_id     => params[:project][:aws_access_key],
          :secret_access_key => params[:project][:aws_secret_access_key]
      )

      begin
        check.instances.inject({}) { |m, i| m[i.id] = i.status; m }


      github_private = params[:project][:github_private] ? true : false
      project = Project.create!(params[:project].except(:support, :github_private).merge(:github_private => github_private))
      respond_with(project, :location => :projects)
      rescue Object => e
        render :text => e.to_s, :status => :error
        return
      end
    end
  end

  private

  def github_authorised?
    !!session[:token]
  end
end
