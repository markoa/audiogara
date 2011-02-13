Audiogara = {

  initUser: function(userId) {

    $(".hideCmds").hide();

    $(".hide").click(function() {
      $(this).parent().find(".hideCmds").fadeIn();
      return false;
    });

    $(".hideArtist").click(function() {
      var artistId = $(this).attr("data-artist-id");
      var link = this;
      $.post("/users/" + userId + "/ignore-artist/" + artistId, function(data, status) {
        if (status === "success") {
          torrent = $(link).closest(".torrent");
          torrent.fadeOut();
          torrent.remove();
        } else {
          alert("Yikes, an error occurred.");
        }
      });
      return false;
    });
  }
};
