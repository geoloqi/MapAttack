
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
		}
		if(typeof push.gamestate != "undefined" && push.gamestate == "done") {
			window.location = "/game/"+$("#layer_id").val()+"/complete";
		}
		if(typeof push.scores != "undefined") {
			receiveScores(push.scores);
		}
	}
}

$(document).ready(function() {
	updateGame(true);
});