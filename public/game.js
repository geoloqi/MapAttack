
var cg = {
	s: function(w,h) {
		return new google.maps.Size(w,h);
	},
	p: function(w,h) {
		return new google.maps.Point(w,h);
	}
}

var coinSpriteURL = "/img/gameboard-sprite.png";
var coinHeight = 25;
var coins = {
	10: {
		red: new google.maps.MarkerImage(coinSpriteURL, cg.s(17,17),  cg.p(0, 277), cg.p(17/2, 17/2)),
		blue: new google.maps.MarkerImage(coinSpriteURL, cg.s(17,17), cg.p(0, 302), cg.p(17/2, 17/2)),
		grey: new google.maps.MarkerImage(coinSpriteURL, cg.s(17,17), cg.p(0, 327), cg.p(17/2, 17/2))
	},
	20: {
		red: new google.maps.MarkerImage(coinSpriteURL, cg.s(19,19),  cg.p(17, 276), cg.p(19/2, 19/2)),
		blue: new google.maps.MarkerImage(coinSpriteURL, cg.s(19,19), cg.p(17, 300), cg.p(19/2, 19/2)),
		grey: new google.maps.MarkerImage(coinSpriteURL, cg.s(19,19), cg.p(17, 326), cg.p(19/2, 19/2))
	},
	30: {
		red: new google.maps.MarkerImage(coinSpriteURL, cg.s(21,21),  cg.p(36, 275), cg.p(21/2, 21/2)),
		blue: new google.maps.MarkerImage(coinSpriteURL, cg.s(21,21), cg.p(36, 299), cg.p(21/2, 21/2)),
		grey: new google.maps.MarkerImage(coinSpriteURL, cg.s(21,21), cg.p(36, 325), cg.p(21/2, 21/2))
	},
	50: {
		red: new google.maps.MarkerImage(coinSpriteURL, cg.s(25,25),  cg.p(57, 273), cg.p(25/2, 25/2)),
		blue: new google.maps.MarkerImage(coinSpriteURL, cg.s(25,25), cg.p(57, 297), cg.p(25/2, 25/2)),
		grey: new google.maps.MarkerImage(coinSpriteURL, cg.s(25,25), cg.p(57, 323), cg.p(25/2, 25/2))
	}
};


var playerIconSize = new google.maps.Size(32, 32);
var playerIconOrigin = new google.maps.Point(0,0);
var playerIconAnchor = new google.maps.Point(16, 32);
var playerIcons = {
	blue: new google.maps.MarkerImage("http://www.google.com/intl/en_us/mapfiles/ms/icons/blue-dot.png", playerIconSize, playerIconOrigin, playerIconAnchor),
	red: new google.maps.MarkerImage("http://www.google.com/intl/en_us/mapfiles/ms/icons/red-dot.png", playerIconSize, playerIconOrigin, playerIconAnchor)
}

// player icon: '/player/' + player.geoloqi_id + "/" + player.team + '/map_icon.png'

  $(function(){
  	var people = [];
  	var pellets = [];
	
  	var myOptions = {
  		zoom: 17,
  		center: new google.maps.LatLng(45.512, -122.643),
  		mapTypeId: google.maps.MapTypeId.ROADMAP,
  		mapTypeControl: false
  	};

  	// Create the main map
  	map = new google.maps.Map(document.getElementById("map"), myOptions);

      // Load the initial game state and place the pins on the map. Sample data in pellets.json

  	updateGame();

  	function updateGame() {
  		$.ajax({ 
  			url: "/game/"+$("#layer_id").val()+"/status.json",
  			dataType: "json", 
  			success: function(data) {
  				// Add the new pellets
  				$(data.places).each(function(i, pellet) {
  					if(typeof pellet.team == "undefined" || pellet.team == null || pellet.team == "") {
  						markerIcon = coins[pellet.points].grey;
  					} else {
  						markerIcon = coins[pellet.points][pellet.team];
  					}

					if(typeof pellets[pellet.place_id] == "undefined") {
	  					pellets[pellet.place_id] = {
	  						id: pellet.place_id,
	  						team: pellet.team,
	  						marker: new google.maps.Marker({
	  							position: new google.maps.LatLng(pellet.latitude, pellet.longitude),
	  							map: map,
	  							icon: markerIcon
	  						})
	  					};
	  				} else {
	  					// Pellet is already on the screen, decide whether we should update it
	  					var p = pellets[pellet.place_id];
	  					if(pellet.team != p.team) {
	  						p.marker.setMap(null);
	  						p.marker = new google.maps.Marker({
	  							position: new google.maps.LatLng(pellet.latitude, pellet.longitude),
	  							map: map,
	  							icon: markerIcon
	  						});
	  						p.team = pellet.team;
	  					}
	  				}
  				});
  				
  				// Move the player markers and update the scoreboard
  				$("#scoreboard-red, #scoreboard-blue").html("");
  				var total_score = {
  					red: 0,
  					blue: 0
  				};
  				
  				$(data.players).each(function(i, player){
  					if($("#player-score-" + player.geoloqi_id).length == 0) {
	  					$("#"+player.team+"-team-players").append('<li id="player-score-' + player.geoloqi_id + '"><img src="' + player.profile_image + '" />'
	  						+ '<h3>' + player.name + '</h3>'
	  						+ '<span class="points">' + player.score + '</span>'
	  						+ '</li>');
	  				} else {
	  					$("#player-score-" + player.geoloqi_id + " .points").html(player.score);
	  				}
					total_score[player.team] += player.score;
					if(typeof player.location.location != "undefined") {
	  					receivePlayerData({
	  						id: player.name, 
	  						team: player.team,
	  						latitude: player.location.location.position.latitude, 
	  						longitude: player.location.location.position.longitude
	  					});
	  				}
  				});
  				$(".red-score-value").html(total_score.red);
  				$(".blue-score-value").html(total_score.blue);

			  	setTimeout(updateGame, 5000);
  		    }
  		});
  	}

    function deletePellet(id) {
  	  $(pellets).each(function(i, pellet) {
  		  if(pellet.id == id) {
  		    // console.log("Pellet id removal");
        	pellet.marker.setMap(null);
        }
      });
    }
  
    function receivePlayerData(serverMessage) {
  		var id = serverMessage.id;
  		var latitude = serverMessage.latitude;
  		var longitude = serverMessage.longitude;
  		var myLatLng = new google.maps.LatLng(latitude, longitude);
  		var exists;
  		for(i=0;i<people.length;i++){
  			var person = people[i];
  			if(person.id != id){
			
  			}else{
  				exists = 1;
  				// console.log(serverMessage);
  				person.marker.setPosition(myLatLng);
  			}
  		}
  		if(!exists){
  			//console.log("creating user");
  			var marker = new google.maps.Marker({
  				position: myLatLng,
  				map: map,
  				title: serverMessage.id,
  				icon: playerIcons[serverMessage.team]
  			});
  			serverMessage.marker = marker;
  			people.push(serverMessage);
  		}
    }
  });