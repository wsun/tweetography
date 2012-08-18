class ChangeLatlonToFloat < ActiveRecord::Migration
  def up
  	change_column :searches, :lat, :float, :precision => 10, :scale => 6
  	change_column :searches, :lon, :float, :precision => 10, :scale => 6
  end

  def down
  	change_column :searches, :lat, :decimal, :precision => 10, :scale => 7
  	change_column :searches, :lon, :decimal, :precision => 10, :scale => 7
  end
end
