class ChangeCreatedColumnName < ActiveRecord::Migration
  def up
    rename_column :searches, :created, :tweeted
  end

  def down
    rename_column :searches, :tweeted, :created
  end
end
