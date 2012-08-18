class AddQueryToSearch < ActiveRecord::Migration
  def change
    add_column :searches, :query, :integer
  end
end
