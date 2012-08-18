class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.datetime :created
      t.string :user
      t.integer :userid
      t.string :name
      t.string :text
      t.string :loc
      t.string :timezone
      t.integer :statuses
      t.integer :followers
      t.integer :friends
      t.string :source
      t.decimal :lat, :precision => 10, :scale => 7
      t.decimal :lon, :precision => 10, :scale => 7
      t.integer :mood

      t.timestamps
    end
  end
end
