class AddSourceToTorrents < ActiveRecord::Migration
  def self.up
    add_column :torrents, :source, :integer
  end

  def self.down
    remove_column :torrents, :source
  end
end
