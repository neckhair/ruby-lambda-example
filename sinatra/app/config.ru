require "rubygems"
require "bundler/setup"
Bundler.require(:default)

require_relative "server"

set :root, File.dirname(__FILE__)
set :views, proc { File.join(root, "views") }

run Sinatra::Application
