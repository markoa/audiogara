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
          torrents = $(".torrent[data-artist-id=" + artistId + "]");
          torrents.fadeOut();
          torrents.remove();
        } else {
          alert("Yikes, an error occurred.");
        }
      });
      return false;
    });

    $(".hideTorrent").click(function() {
      var torrentId = $(this).attr("data-torrent-id");
      var link = this;
      $.post("/users/" + userId + "/ignore-album/" + torrentId, function(data, status) {
        if (status === "success") {
          torrent = $("#torrent_" + torrentId);
          torrent.fadeOut();
          torrent.remove();
        } else {
          alert("Yikes, an error occurred.");
        }
      });
      return false;
    });

    $(".haveThis").click(function() {
      var torrentId = $(this).attr("data-torrent-id");
      var link = this;
      $.post("/users/" + userId + "/own-album/" + torrentId, function(data, status) {
        if (status === "success") {
          torrent = $("#torrent_" + torrentId);
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
