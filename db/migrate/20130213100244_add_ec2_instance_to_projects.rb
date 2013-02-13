class AddEc2InstanceToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :ec2_instance, :string
  end
end
