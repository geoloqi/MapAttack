var GameMap = {
	fitToRadius: function(radius) {
	  var center = map.getCenter();
	  var topMiddle = google.maps.geometry.spherical.computeOffset(center, radius, 0);
	  var bottomMiddle = google.maps.geometry.spherical.computeOffset(center, radius, 180);
	  var bounds = new google.maps.LatLngBounds();
	  bounds.extend(topMiddle);
	  bounds.extend(bottomMiddle);
	  map.fitBounds(bounds);
	},

	goToAddress: function(address) {
		var geocoder = new google.maps.Geocoder();
		geocoder.geocode({address: address, bounds: map.getBounds()}, function(response) {
				if(response.length > 0) {
					var place = response[0];
					map.setCenter(place.geometry.location);
				}
			}
		);
	}
}
