	var lastRequestTime = 0;

    // Load the initial game state and place the pins on the map. Sample data in pellets.json
    // This function polls the game server for data.
  	updateGame();
  	function updateGame() {
  		$.ajax({ 
  			url: "/game/"+$("#layer_id").val()+"/status.json",
  			type: "GET",
  			data: {after: lastRequestTime},
  			dataType: "json", 
  			success: function(data) {
  				// Add the new pellets
  				$(data.places).each(function(i, pellet) {
					receiveCoinData(pellet);
  				});
  				
  				// Move the player markers and update the scoreboard
  				var total_score = {
  					red: 0,
  					blue: 0
  				};
  				
  				$("#num-players").html(data.players.length + " Players");
  				
  				$(data.players).each(function(i, player){

					total_score[player.team] += player.score;
					if(typeof player.location.location != "undefined") {
	  					receivePlayerLocation({
	  						id: player.geoloqi_id,
	  						username: player.name, 
	  						team: player.team,
	  						latitude: player.location.location.position.latitude, 
	  						longitude: player.location.location.position.longitude,
							useDefaultIcon: useDefaultIcon
	  					});
	  				}
  				});
  				receiveScores(total_score.red, total_score.blue);

				lastRequestTime = Math.round((new Date()).getTime() / 1000);
			  	setTimeout(updateGame, 5000);
  		    }
  		});
  	}
