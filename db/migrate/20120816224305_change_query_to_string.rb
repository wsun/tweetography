class ChangeQueryToString < ActiveRecord::Migration
  def up
    change_column :searches, :query, :string
  end

  def down
    change_column :searches, :query, :integer
  end
end
