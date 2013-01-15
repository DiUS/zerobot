class LaunchpadController < ApplicationController
    def index
      redirect_to new_project_url
    end
end