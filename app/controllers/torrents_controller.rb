class TorrentsController < ApplicationController

  def index
    page = params[:page].present? ? params[:page] : 1

    @torrents = Torrent.with_known_artist.paginate(
      :page => page,
      :order => "created_at DESC"
    )
  end

  def all
    page = params[:page].present? ? params[:page] : 1

    @torrents = Torrent.paginate(
      :page => page,
      :order => "created_at DESC"
    )
  end
end
