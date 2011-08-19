
var cg = {
	s: function(w,h) {
		return new google.maps.Size(w,h);
	},
	p: function(w,h) {
		return new google.maps.Point(w,h);
	},
	playerImage: function(id, team, useDefault) {
		return new google.maps.MarkerImage("/player/"+id+"/"+team+"/map_icon.png", new google.maps.Size(38, 31), new google.maps.Point(0,0), new google.maps.Point(10, 30));
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

var people = [];
var pellets = [];

// player icon: '/player/' + player.geoloqi_id + "/" + player.team + '/map_icon.png'

$(function(){
	if(!document.getElementById("map")) {
		return;
	}
	
	var myOptions = {
		zoom: 17,
		center: new google.maps.LatLng(37.4313, -122.1647),
		mapTypeId: google.maps.MapTypeId.ROADMAP,
		mapTypeControl: true
	};
	
	// Create the main map
	map = new google.maps.Map(document.getElementById("map"), myOptions);
});

function receiveScores(red, blue) {
	$(".red-score-value").html(red);
	$(".blue-score-value").html(blue);
}

function deleteCoin(id) {
	$(pellets).each(function(i, pellet) {
		if(pellet.id == id) {
			pellet.marker.setMap(null);
		}
	});
}

function receiveCoinData(pellet) {
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
		// Coin is already on the screen, decide whether we should update it
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
	
	if(typeof pellet.score_red != "undefined"){ 
		receiveScores(pellet.score_red, pellet.score_blue);
	}
}

function receivePlayerScore(player) {
	if($("#player-score-" + player.geoloqi_id).length == 0) {
		if(player.name.match('^_')) {
			player.name = '';
		}
		var useDefaultIcon = false;
		if(player.profile_image == '' || player.profile_image == null) {
			useDefaultIcon = true;
			if(player.team == "red") {
				player.profile_image = "/img/blank-profile-red.png";
			} else {
				player.profile_image = 'http://beta.geoloqi.com/themes/standard/assets/images/profile-blank.png';
			}
		}
		$("#"+player.team+"-team-players").append('<li id="player-score-' + player.geoloqi_id + '"><img src="' + player.profile_image + '" />'
			+ '<h3>' + player.name + '</h3>'
			+ '<span class="points">' + player.score + '</span>'
			+ '</li>');
	} else {
		$("#player-score-" + player.geoloqi_id + " .points").html(player.score);
	}
}

function receivePlayerLocation(data) {
	var id = data.id;
	var myLatLng = new google.maps.LatLng(data.latitude, data.longitude);
	var exists;
	for(i=0;i<people.length;i++){
		var person = people[i];
		if(person.id != id){
	
		}else{
			exists = 1;
			person.marker.setPosition(myLatLng);
		}
	}
	if(!exists){
		// TODO: We need "team". Look up which team the user is on. Add a route to controller.rb to retrieve the player info?
		var team = "";
		
		var marker = new google.maps.Marker({
			position: myLatLng,
			map: map,
			title: data.username,
			icon: cg.playerImage(id, team, data.useDefaultIcon)
		});
		data.marker = marker;
		people.push(data);
	}
}

