require 'rack/test'
require 'rspec'
require 'sinatra/async/test'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  include Sinatra::Async::Test::Methods

  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }
