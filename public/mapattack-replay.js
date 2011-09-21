

// This function is run by the iPhone or Android app, which pass an
// object to the function. The object will have come from either
// Geoloqi with the location of someone in the game, or from the game
// server with data about the coins on the map.
function LQHandlePushData(data) {

	// Location broadcasts from the group will have a user_id key
	if(typeof data.user_id != "undefined"){

		receivePlayerLocation({
			id: data.user_id,
			username: data.username,
			latitude: data.latitude,
			longitude: data.longitude
		});
	
	// Custom push data from mapattack will contain the "mapattack" key
	} else if(typeof data.mapattack != "undefined") {
		var push = data.mapattack;
		if(typeof push.place_id != "undefined"){
			receiveCoinData(data.mapattack);
			console.debug(data.mapattack.team);
		}
		if(typeof push.scores != "undefined") {
			for(var i in push.scores) {
				$("#player-score-" + i + " .points").html(push.scores[i]);
			}
		}
	}
}

$(document).ready(function() {
	setup = true;
	updateGame(true);

setTimeout(function(){
	$.getJSON("/game.json", function(data){

		$(".team-players .points, .blue-score-value, .red-score-value").html("0");
		
		startTime = data['start'];
		endTime = data['end'];
		clock = startTime;
		setInterval(function(){
			if(typeof data[clock] != "undefined") {
				// console.debug(data[clock]);
				for(var i in data[clock]){
					LQHandlePushData(data[clock][i]);
				}
			}
		
			clock++;
		}, (1000/10));
	});
}, 2000);

});


