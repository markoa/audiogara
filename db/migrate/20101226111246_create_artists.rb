class CreateArtists < ActiveRecord::Migration
  def self.up
    create_table :artists do |t|
      t.string :name
      t.string :mbid
      t.string :lastfm_url
      t.string :image_small_url
      t.string :image_medium_url
      t.string :image_large_url
      t.string :image_extralarge_url
      t.string :image_mega_url

      t.timestamps
    end
  end

  def self.down
    drop_table :artists
  end
end
