class SimilarArtistsController < ApplicationController

  before_filter :find_artist

  def index
    @similar_artists = @artist.similar_artists(:include => :artist, :order => "score DESC")
  end

  protected

  def find_artist
    @artist = Artist.find(params[:artist_id])
  end
end
