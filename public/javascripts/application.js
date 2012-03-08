$(document).ready(function () {
  $("#welcome_all_users .user").click(function() {
    var $this = $(this);
    Actions.login($this.attr("data-user-id"), $this.attr("data-user-name"), $this.attr("data-user-picture"));
  });
  $(document).bind("ajaxComplete", Response.receive);
});

var Actions = {
  login: function(user_id, user_name, user_picture) {
      var at_a_time = Math.floor($("#welcome_all_users .user").length / 4);
      var fade_out_welcome_users_count = 0;
      var num_times = 4;
      var fade_out_welcome_users_timer = setInterval(function() {
        fade_out_welcome_users_count += 1;
        Misc.fade_out_welcome_users(at_a_time, fade_out_welcome_users_count, num_times);
        if (fade_out_welcome_users_count === num_times) {
          clearInterval(fade_out_welcome_users_timer);
        }
      }, 450);
    $.post("/login", {user_id: user_id}, function(data, text_status, jquery_xhr) {
      if (jquery_xhr.status == 202) {
        User.set(user_id, user_name, user_picture);
      }
    });
  },
  set_up_radio_interface: function() {
    $("h1").fadeOut(function() {
      $(this).text($("title").text()).fadeIn();
    });
    $("#player").fadeIn();
    $("#user_info #user_info_picture img").attr("src", User.picture);
    $("#user_info #user_info_name").text(User.name);
    $("#user_info").fadeIn();
    $("#playlist").fadeIn();
    $("#controls a").click(function() {
      Player[$(this).attr("id").replace("_button", "")]();
    });
  }
};

var User = {
  id: null,
  name: null,
  picture: null,
  set: function(user_id, user_name, user_picture) {
    User.id = user_id;
    User.name = user_name;
    User.picture = user_picture;
  }
};

var Player = {
  play: function() {
    this.send_command("play");
    this.set_status("playing");
  },
  pause: function() {
    this.send_command("pause");
    this.set_status("paused");
  },
  veto: function() {
    this.send_command("veto");
  },
  send_command: function(command) {
    var track = Playlist.current_track;
    $.post("/" + command, {_method:"put", track:track.id});
  },
  status: null,
  set_status: function(new_status) {
    this.status = new_status;
    this.show_play_or_pause_button();
  },
  initialized: false,
  initialize: function() {
    this.initialized = true;
    this.refresh();
  },
  refresh: function() {
    var $now_playing = $("#player #now_playing");
    var $now_playing_image = $now_playing.find("img");
    $now_playing_image.attr("src", Playlist.current_track.image);
    var $now_playing_info = $now_playing.find("#now_playing_info");
    $now_playing_info.html("<h3></h3>");
    var $now_playing_info_heading = $now_playing_info.find("h3");
    $now_playing_info_heading.text(Playlist.current_track.name());
    var date = new Date(Playlist.current_track.release_date);
    $now_playing_info_heading.after("Track #" + Playlist.current_track.track_number + " on " + Playlist.current_track.album + " (" + date.getDate() + "/" + (date.getMonth() + 1) + "/" + date.getFullYear() + ")");
  },
  show_play_or_pause_button: function() {
    var $player_controls = $("#player #controls");
    var $play_button = $player_controls.find("#play_button");
    var $pause_button = $player_controls.find("#pause_button");
    if (this.status == "paused") {
      $play_button.show();
      $pause_button.hide();
    }
    else {
      $play_button.hide();
      $pause_button.show();
    }
  }
};

var Misc = {
  fade_out_welcome_users: function(at_a_time, count, num_times) {
    if (count !== num_times) {
      for (i = 0; i < at_a_time; i++) {
        var $users = $("#welcome_all_users .user").not(function(index) {
          // Don't select this user for randomizing if it's already invisible.
          return this.style.opacity == "0";
        });
        var random_index = Math.floor(Math.random() * $users.length);
        $($users[random_index]).animate({opacity: 0});
      }
    }
    else {
      $("#welcome_all_users .user, #welcome_all_users").fadeOut(function() {
        $(this).remove();
        if ($(this).attr("id") === "welcome_all_users") {
          Actions.set_up_radio_interface();
        }
      });
    }
  }
};

var Response = {
  receive: function(event, xhr, ajax_options) {
    var response = $.parseJSON(xhr.responseText);
    var response_keys = Object.keys(response);

    // Make sure the playlist key is at the start.
    playlist_index = response_keys.indexOf("playlist");
    if (playlist_index != -1) {
      response_keys.splice(playlist_index, 1);
      response_keys.unshift("playlist");
    }

    $.each(response_keys, function(index, value) {
      Response["receive_" + value](response[value]);
    });
  },
  receive_playlist: function(playlist) {
    Playlist.empty();
    $.each(playlist, function(index, track) {
      Playlist.add_track(track);
    });
    var $playlist_ui = $("#playlist ul");
    $playlist_ui.empty();
    $.each(Playlist.tracks, function(index, track) {
      $playlist_ui.append("<li>" + track.name() + "</li>");
    });
  },
  receive_player: function(player) {
    Player.set_status(player.status);
    Playlist.set_current_track(player.current_track);
    if (Player.initialized == false) {
      Player.initialize();
    }
    else {
      Player.refresh();
    }
  },
  receive_next_update_time: function(seconds) {
    setTimeout(function() {
      $.get("/update/all");
    }, (seconds * 1000));
  }
};

var Playlist = {
  tracks: [],
  add_track: function(track) {
    this.tracks.push(new this.Track(track));
  },
  empty: function() {
    this.tracks = [];
  },
  Track: function(data) {
    var self = this;
    self.name = function() {
      return this.artist + " - " + this.title;
    };
    var init = function(data) {
      $.each(Object.keys(data), function(index, attribute) {
        self[attribute] = data[attribute];
      });
    };
    init(data);
  },
  current_track: null,
  set_current_track: function(current_track) {
    var self = this;
    $.each(this.tracks, function(index, track) {
      if (track.id === current_track) {
        self.current_track = track;
        return false;
      }
    });
  }
};
