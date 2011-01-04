class AddUserIdArtistNameIndexToInterests < ActiveRecord::Migration
  def self.up
    remove_index :interests, :user_id
    add_index :interests, [:user_id, :artist_name]
  end

  def self.down
    remove_index :interests, [:user_id, :artist_name]
    add_index :interests, :user_id
  end
end
