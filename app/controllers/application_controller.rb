require 'dupondius'
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter {
    headers['X-Refspec'] = Dupondius::Version.refspec
  }

  before_filter :protect_environment_management

  def protect_environment_management
    return unless Rails.configuration.demo_enabled

    if self.controller_name == 'instances'
        if self.action_name == 'update'
            render :json => {:error => 'Sorry, you need to be authenticated to perform this action'}, :status => 500
            return
        end
    end

    if self.controller_name == 'stacks'
        if self.action_name == 'update' || self.action_name == 'create' || self.action_name == 'destroy'
            render :json => {:error => 'Sorry, you need to be authenticated to perform this action'}, :status => 500
            return
        end
    end
  end
end
