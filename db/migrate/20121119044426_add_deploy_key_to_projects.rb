class AddDeployKeyToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :deploy_key, :text
  end
end
