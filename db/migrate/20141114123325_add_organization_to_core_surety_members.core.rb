# This migration comes from core (originally 20141114123036)
class AddOrganizationToCoreSuretyMembers < ActiveRecord::Migration[4.2]
  def change
    add_column :core_surety_members, :organization_id, :integer
    add_column :core_surety_members, :organization_department_id, :integer

    add_index :core_surety_members, :organization_id
  end
end
