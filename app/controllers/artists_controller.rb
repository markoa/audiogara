class ArtistsController < ApplicationController

  def index
    @artist_count = Artist.count

    page = params[:page].present? ? params[:page] : 1

    @artists = Artist.paginate(
      :page => page,
      :order => "name ASC"
    )
  end

  def show
    @artist = Artist.find(params[:id], :include => :torrents)
    @similar_artists = @artist.similar_artists.known
  end
end
