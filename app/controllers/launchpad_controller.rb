class LaunchpadController < ApplicationController
    before_filter :authenticate_user! if Rails.configuration.auth_enabled
    
    def index
      redirect_to new_project_url
    end
end