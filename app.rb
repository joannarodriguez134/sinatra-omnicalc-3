require "sinatra"
require "sinatra/reloader"
require "http"
require "sinatra/cookies"

get("/zebra") do
  cookies.store("color", "purple")
  cookies.store("sport", "tennis")
  # or, similarly, we can use a more concise technique: []
  cookies["color"] = "purple"
  cookies["sport"] = "tennis"

  # The cookies hash would now look like:
  #    { "color" => "purple", "sport" => "tennis" }
	
  "We stored two values, under the keys 'color' and 'sport'"
end

get("/") do
  "
  <h1>Welcome to your Sinatra App!</h1>
  <p>Define some routes in app.rb</p>
  "
end

get("/umbrella") do
  erb(:umbrella_form)
end

post("/process_umbrella") do
  @user_location = params.fetch("user_loc")

  @url_encoded_string = @user_location.gsub(" ", "+")

  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@url_encoded_string}&key=" + ENV.fetch("GMAPS_KEY")
  @raw_response = HTTP.get(gmaps_url).to_s
  # gmaps_url calls the entire response
  # to_s gets only the body of the response
  @parsed_response = JSON.parse(@raw_response)

  @loc_hash = @parsed_response.dig("results", 0, "geometry", "location")

  # dig is a shortcut method used to dig through JSON (instead of using .fetch and .at)
  # use strings for hashes & use numbers for arrays

  @latitude = @loc_hash.fetch("lat")
  @longitude = @loc_hash.fetch("lng")

  cookies["last_location"] = @user_location
  cookies["last_lat"] = @latitude
  cookies["last_lng"] = @longitude

  erb(:umbrella_results)
end
