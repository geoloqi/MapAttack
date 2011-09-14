
$(document).ready(function() {
	updateGame(true);
	
	var socket = io.connect("http://subscribe.geoloqi.com:81");
		socket.on('enter group token', function(data) {
		socket.emit('token', 'group-'+$("#group_token").val());
	});
	socket.on('group', function(location) {
		var data = eval("("+location+")");
		
		if(typeof data.user_id != "undefined"){
	
			receivePlayerLocation({
				id: data.user_id,
				username: data.username,
				latitude: data.latitude,
				longitude: data.longitude
			});
			
		} else if(typeof data.mapattack != "undefined") {

			var push = data.mapattack;
			if(typeof push.place_id != "undefined"){
				receiveCoinData(data.mapattack);
				
				$("#player-info").addClass("blink");
				$("#player-info .message").html(push.points+" points!");
				setTimeout(function(){
					$("#player-info").removeClass("blink");
					$("#player-info .message").html("");
				}, 1200);
			}
			
		}
	});
});