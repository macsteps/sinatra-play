require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require "sinatra/reloader" if development?
require 'json'
require 'rest_client'

def get_result(url)
  api_result = RestClient.get url
  JSON.parse(api_result)
end

get '/weather' do
  api_key = "51bc60b925e585503730a681d5854277"
  # {"_id":5368381,"name":"Los Angeles County","country":"US","coord":{"lon":-118.200912,"lat":34.366661}}
  #api_result = RestClient.get "api.openweathermap.org/data/2.5/weather?id=5368381&units=imperial&APPID=#{api_key}"
  #jhash = JSON.parse(api_result)
  jhash = get_result("http://api.openweathermap.org/data/2.5/weather?id=5368381&units=imperial&APPID=#{api_key}")
  output = ''

  jhash['main'].each do |f|
    title_tag = f[0]
    info_item = f[1]
    output << "<tr><td>#{title_tag}</td><td>#{info_item}</td></tr>"
  end

  erb :index, :locals => {results: output}
end

get '/geo' do
  erb :get_city
end

post '/geo' do
  city = params[:city].gsub(' ', '').downcase
  jhash = get_result("http://maps.googleapis.com/maps/api/geocode/json?address=#{city}&sensor=false")
  output = ''

  formatted_address = jhash.first[1][0]["formatted_address"]
  lattitude = jhash.first[1][0]["geometry"]["location"]["lat"]
  longitude = jhash.first[1][0]["geometry"]["location"]["lng"]
  output << "<tr><td>#{formatted_address}</td><td>#{lattitude}</td><td>#{longitude}</td</tr>"

  erb :geo, :locals => {results: output}, :cache => false
end
