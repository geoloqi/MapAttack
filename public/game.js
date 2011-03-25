
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
  	setInterval(updateGame, 5000);

  	updateLocations();
  	setInterval(updateLocations, 5000);

  	function updatePellets() {
  		$.ajax({ 
  			url: "/game/"+$("#layer_id").val()+"/setup.json",
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
  				
  				// Update the scoreboard
  				
  				
  				
  				// Move the player markers
  				$(data.players).each(function(i, p){
  					receivePlayerData({id: p.username, latitude:p.location.position.latitude, longitude:p.location.position.longitude});
  				});
  		    }
  		});
  	}

  	function updateScoreBoard() {
  		$.ajax({
  			url: "/scores.json",
  			dataType: 'json',
  			success: function(data) {
  				//data = [{profile_image:"http://a2.twimg.com/profile_images/553711946/aaronpk-bw_normal.jpg", name:"aaronpk", score:100}];
  				$("#scoreboard").html("");
  				$(data).each(function(i, player){
  					$("#scoreboard").append('<div class="player"><div class="pic"><img src="' + player.profile_image + '" /></div><div class="name">' + player.name + '</div><div class="score">' + player.score + '</div><div class="end"></div></div>');
  				});
  			}
  		});
  	}

    function deletePellet(id) {
  	  $(pellets).each(function(i, pellet) {
  		  if(pellet.id == id) {
  		    console.log("Pellet id removal");
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
  				console.log("moving existing user");
  				person.marker.setPosition(myLatLng);
  			}
  		}
  		if(!exists){
  			//console.log("creating user");
  			var marker = new google.maps.Marker({
  				position: myLatLng,
  				map: map
  			});
  			serverMessage.marker = marker;
  			people.push(serverMessage);
  		}
    }
  });