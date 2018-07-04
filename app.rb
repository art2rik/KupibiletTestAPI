require 'sinatra'
require 'active_support'
require 'em-hiredis'
require 'eventmachine'
require 'sinatra/async'
require 'yaml'

register Sinatra::Async

set :server, :thin

def redis
  config = YAML.load_file(File.join(__dir__, 'config.yml'))
  @redis ||= EM::Hiredis.connect(config[:redis])
end

helpers do
  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end

  def generate_short_url(url)
    rand(8**url.length).to_s(36)
  end
end

apost '/' do
  content_type :json
  url = params['longUrl']

  if url_valid?(url)
    begin
      short_url =  generate_short_url(url)
      key       = "link:#{short_url}"
      redis.setnx(key, url)
    end until redis.exists(key) # Loop while not get unique key

    full_url = "http://#{request.host}:#{request.port}/#{short_url}"
    status 200
    body({url: full_url}.to_json)
  else
    status 404
    body({message: "Incorrect URL"}.to_json)
  end
end

aget '/:link' do |link|
  redis.get("link:#{link}").callback { |url|
    if url
      headers Location: url
      status 301
      body
    else
      content_type :json
      status 404
      message = "There is no such (#{link}) short url"
      body({message: message}.to_json)
    end
  }
end



