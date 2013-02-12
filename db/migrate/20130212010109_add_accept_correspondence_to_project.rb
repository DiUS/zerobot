class AddAcceptCorrespondenceToProject < ActiveRecord::Migration
  def change
    add_column :projects, :accept_correspondence, :boolean
  end
end
