class CreateIgnoredArtists < ActiveRecord::Migration
  def self.up
    create_table :ignored_artists do |t|
      t.references :artist
      t.references :user

      t.timestamps
    end

    add_index :ignored_artists, :user_id
  end

  def self.down
    remove_index :ignored_artists, :user_id
    drop_table :ignored_artists
  end
end
