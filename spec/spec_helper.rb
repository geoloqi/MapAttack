ENV['RACK_ENV'] = 'test'
raise 'Forget it.' if ENV['RACK_ENV'] == 'production'
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'environment.rb')
require File.dirname(__FILE__) + '/spec_helper'
require 'eventmachine'
Bundler.require :test
DataMapper.auto_migrate!