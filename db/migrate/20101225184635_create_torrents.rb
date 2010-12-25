class CreateTorrents < ActiveRecord::Migration
  def self.up
    create_table :torrents do |t|
      t.string :title
      t.string :guid
      t.string :link
      t.datetime :published_at
      t.string :artist_name
      t.string :album_name

      t.timestamps
    end
  end

  def self.down
    drop_table :torrents
  end
end
