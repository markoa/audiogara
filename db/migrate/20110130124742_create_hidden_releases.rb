class CreateHiddenReleases < ActiveRecord::Migration
  def self.up
    create_table :hidden_releases do |t|
      t.string :artist_name
      t.string :album_name
      t.integer :reason
      t.references :user

      t.timestamps
    end

    add_index :hidden_releases, :user_id
  end

  def self.down
    remove_index :hidden_releases, :user_id
    drop_table :hidden_releases
  end
end
