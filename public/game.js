
var coinSpriteURL = "http://loqi.me/pdx-pacmap/coins.png";
var coinWidth = 14;
var coinSpriteSize = new google.maps.Size(coinWidth, coinWidth);
var coinSpriteAnchor = new google.maps.Point(coinWidth/2, coinWidth/2);
var coins = {
	10: {
		blue: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(0, 0), coinSpriteAnchor),
		red: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(0, coinWidth), coinSpriteAnchor),
		grey: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(0, coinWidth*2), coinSpriteAnchor)
	},
	20: {
		blue: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(coinWidth, 0), coinSpriteAnchor),
		red: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(coinWidth, coinWidth), coinSpriteAnchor),
		grey: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(coinWidth, coinWidth*2), coinSpriteAnchor)
	},
	30: {
		blue: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(coinWidth*2, 0), coinSpriteAnchor),
		red: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(coinWidth*2, coinWidth), coinSpriteAnchor),
		grey: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(coinWidth*2, coinWidth*2), coinSpriteAnchor)
	},
	50: {
		blue: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(coinWidth*3, 0), coinSpriteAnchor),
		red: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(coinWidth*3, coinWidth), coinSpriteAnchor),
		grey: new google.maps.MarkerImage(coinSpriteURL, coinSpriteSize, new google.maps.Point(coinWidth*3, coinWidth*2), coinSpriteAnchor)
	}
};

var playerIconSize = new google.maps.Size(32, 32);
var playerIconOrigin = new google.maps.Point(0,0);
var playerIconAnchor = new google.maps.Point(16, 32);
var playerIcons = {
	blue: new google.maps.MarkerImage("http://www.google.com/intl/en_us/mapfiles/ms/icons/blue-dot.png", playerIconSize, playerIconOrigin, playerIconAnchor),
	red: new google.maps.MarkerImage("http://www.google.com/intl/en_us/mapfiles/ms/icons/red-dot.png", playerIconSize, playerIconOrigin, playerIconAnchor)
}


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
  					$("#scoreboard-"+player.team).append('<div class="player"><div class="pic"><img src="' + player.profile_image + '" /></div><div class="name">' + player.name + '</div><div class="score">' + player.score + '</div><div class="end"></div></div>');
					total_score[player.team] += player.score;
  					receivePlayerData({
  						id: player.name, 
  						team: player.team,
  						latitude: player.location.location.position.latitude, 
  						longitude: player.location.location.position.longitude
  					});
  				});
  				$("#score-red").html(total_score.red);
  				$("#score-blue").html(total_score.blue);

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
  				icon: playerIcons[serverMessage.team]
  			});
  			serverMessage.marker = marker;
  			people.push(serverMessage);
  		}
    }
  });