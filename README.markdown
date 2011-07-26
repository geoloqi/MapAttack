MapAttack
===

A game! Neat! (description to come)


Install
---

1. Clone the repository.
2. Ensure Xcode is installed on OSX, or the compiler environment for Linux
3. Install RVM! http://rvm.beginrescueend.com/
4. Set your environment to Ruby 1.9: rvm install 1.9.2 && rvm use 1.9.2
5. Install bundler: sudo gem install bundler
6. Install the packages by running this command: bundle install
7. Start the server: bundle exec rackup -s thin -p 4567 -E production  (leave off "-E production" for development)
8. Point your browser to http://localhost:4567

To run tests: bundle exec test/test.rb

config.yml example:
---
development:
  database: "mysql://pacmap:pass@localhost/pacmap_dev"
  oauth_token: 1jd3f3f2blahblah
production:
  database: "mysql://pacmap:pass@localhost/pacmap"
  oauth_token: 23Ejdf32blahblah
