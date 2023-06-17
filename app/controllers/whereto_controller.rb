class WheretoController < ApplicationController
  class Place < Struct.new(:name, :website) 
    def to_markdown
      "<#{website}|#{name}>"
    end
  end
  
  # location
  def index
    p params
    response_url = params[:response_url]
  
    body = { text: "Try McDonald's!" }

    url = URI("https://api.foursquare.com/v3/places/search?query=restaurants&ll=40.733114%2C-73.955605&radius=500&fields=name%2Cwebsite&open_now=true&sort=RATING&limit=30")
    places = fetch_random_places_nearby

    body = { text: "Try one of these: #{places.map(&:to_markdown).to_sentence}" }

    HTTParty.post(response_url, body: body.to_json, headers: {'Content-Type' => 'application/json'})
  end

  private

  huron_fs_url = "https://api.foursquare.com/v3/places/search?query=restaurants&ll=40.733114%2C-73.955605&radius=500&fields=name%2Cwebsite&open_now=true&sort=RATING&limit=30"

  def list_high_rating_places
    HTTParty.get(huron_fs_url, headers: {'Authorization': ENV["FS_API"]})["result"]
  end

  def fetch_random_places_nearby(count: 3, lat: 40.719667, lon: -74.0002553)
    request_url = "https://api.foursquare.com/v3/places/search?query=restaurants&ll=#{lat}%2C#{lon}&radius=500&fields=name%2Cwebsite&open_now=true&sort=RATING&limit=30"
    results = HTTParty.get(huron_fs_url, headers: {'Authorization': ENV["FS_API"]})["result"]
    
    results.map {|result| Place.new(**result)}
  end
end