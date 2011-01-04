class AddCodeToArtists < ActiveRecord::Migration
  def self.up
    add_column :artists, :code, :string
    add_index :artists, :code
  end

  def self.down
    remove_index :artists, :code
    remove_column :artists, :code
  end
end
