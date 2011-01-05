Given "Last.fm is fake" do
  LastFm::Artist.stub(:get_info).and_return({})
  LastFm::Artist.stub(:get_similar).and_return([])
  LastFm::User.stub(:get_top_artists).and_return(["port-royal", "Au Revoir Simone"])
end
