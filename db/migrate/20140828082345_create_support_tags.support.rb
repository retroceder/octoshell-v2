# This migration comes from support (originally 20140827145605)
class CreateSupportTags < ActiveRecord::Migration[4.2]
  def change
    create_table :support_tags do |t|
      t.string :name
      t.timestamps
    end
  end
end
