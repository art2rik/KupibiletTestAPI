require 'sinatra'
require 'active_support'
require 'redis'

set :server, :thin

def redis
  @redis ||= Redis.new
end

helpers do
  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end
end

post '/' do
  content_type :json
  url = params['longUrl']

  if url_valid?(url)
    begin
      short_url = rand(8**url.length).to_s(36) # Generate random str
      key       = "link:#{short_url}"
      redis.setnx(key, url)
    end until redis.exists(key) # Loop while not get unique key

    full_url = "http://#{request.host}:#{request.port}/#{short_url}"
    [200, {url: full_url}.to_json]
  else
    [400, {message: "Incorrect URL"}.to_json]
  end
end

get '/:link' do
  content_type :json
  url = redis.get("link:#{params[:link]}")

  redirect url, 301 unless url.nil?

  message = "There is no such (#{params[:link]}) short url"
  [400, {message: message}.to_json]
end
