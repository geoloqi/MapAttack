PacMap
==================

A game! Neat! (description to come)


Install
---

1) Clone the repository.
2) Ensure Xcode is installed.
3) Install bundler, the ruby package manager: sudo gem install bundler
4) Install the packages by running this command: bundle install
5) Start the server in reload mode with shotgun: bundle exec shotgun -P public
6) Point your browser to http://localhost:9393

For fast, non-development: bundle exec rackup -p 9393

To run tests: bundle exec test/test.rb

config.yml example:
---
development: 
  database:
    adapter: mysql
    username: user
    password: pass
    database: pacmap
    host: localhost
  oauth_token: 1234blahblah
test:
  database:
    adapter: sqlite
    database: test.sqlite3
  oauth_token: phonytokendontusearealone