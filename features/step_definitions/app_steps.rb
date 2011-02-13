Given "Last.fm is fake" do
  LastFm::Artist.stub(:get_info).and_return({})
  LastFm::Artist.stub(:get_similar).and_return([])
  LastFm::User.stub(:get_top_artists).and_return(["port-royal", "Au Revoir Simone"])
  LastFm::User.stub(:get_info).and_return(
    {
      :id => 1,
      :name => "tim",
      :realname => "Tim Tom",
      :url => "",
      :country => "",
      :age => "",
      :gender => "",
      :playcount => 1000,
      :image_small => "",
      :image_medium => "",
      :image_large => "",
      :image_extralarge => "",
      :registered => 2.years.ago.to_date.to_s
    }
  )
end
