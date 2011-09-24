MapAttack
=========

http://mapattack.org

MapAttack is a real-time location based game built on top of the [Geoloqi](http://geoloqi.com) Platform!

MapAttack is a game of territory capture using Geofences and smartphones. Players join the game and are 
automatically assigned to one of two teams. Players then run around to capture invisible coins only visible 
on their mobile phone screen. When a coin is captured, the coin changes color and the team gets points! 
We've hosted games in Portland, Oregon, at Stanford University, and in Sweden!

[Blog Post: Geoloqi launches MapAttack!](http://geoloqi.com/blog/2011/04/geoloqi-launches-mapattack-a-real-time-location-based-mobile-gaming-platform-of-awesomeness)

[Blog Post: MapAttack Weekend Timelapse Footage!](http://geoloqi.com/blog/2011/04/mapattack-at-stanford-university-results-from-game-2)

Want to bring a game to your school or company? Contact us at [play@mapattack.org](mailto:play@mapattack.org) and 
we'll be glad to help you out! You can also follow [@playmapattack](http://www.twitter.com/playmapattack) on 
Twitter for the latest games and news! We'll be bringing it to more campuses and cities starting in Summer 2011.


How to Install
==============

1. Clone the repository.
2. Ensure Xcode is installed on OSX, or the compiler environment for Linux
3. Install RVM! http://rvm.beginrescueend.com/
4. Set your environment to Ruby 1.9: rvm install 1.9.2 && rvm use 1.9.2
5. Install bundler: gem install bundler
6. Install the packages by running this command: bundle install
7. Add database login, OAuth2 credentials and (optional) Google Analytics ID to config.yml (see config.yml.template)
8. Start the server: bundle exec rackup -s thin -p 4567 -E production  (leave off "-E production" for development)
9. Point your browser to http://localhost:4567

To run the tests: bundle exec rake test


License
=======

Copyright 2011 by Geoloqi LLC and contributors.

MapAttack is available under the GPLv2 License.

See LICENSE

If you would like to discuss different licensing options, please contact us at info@geoloqi.com
or on our website, https://geoloqi.com.

