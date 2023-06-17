class WheretoController < ApplicationController
  class Place < Struct.new(:name, :website) 
    def to_markdown
      "<#{website}|#{name}>"
    end
  end
  
  # location
  def index
    response_url = params[:response_url]
  
    url = URI("https://api.foursquare.com/v3/places/search?query=restaurants&ll=40.733114%2C-73.955605&radius=500&fields=name%2Cwebsite&open_now=true&sort=RATING&limit=30")
    places = fetch_random_places_nearby

    body = { response_url: response_url, text: "Try one of these: #{places.map(&:to_markdown).to_sentence}.", in_channel: params[:channel_id], reactions: ["one", "two", "three"] }

    r = HTTParty.post("https://api.slack.com/api/chat.postMessage", body: body.to_json, headers: {'Content-Type' => 'application/json'})
    p r
  end

  private

  def fetch_random_places_nearby(count: 3, lat: 40.719667, lon: -74.0002553)
    request_url = "https://api.foursquare.com/v3/places/search?query=restaurants&ll=#{lat}%2C#{lon}&radius=500&fields=name%2Cwebsite&open_now=true&sort=RATING&limit=30"
    response = HTTParty.get(request_url, headers: {'Authorization': ENV["FS_API"]})
    results = response["results"]
    
    results.map {|result| Place.new(**result)}.sample(count)
  end
end