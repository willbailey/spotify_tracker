require "sinatra"
require "hallon"

api_key = IO.read('./spotify_appkey.key')
session = Hallon::Session.initialize api_key
session.login!(*IO.read('./creds.txt').split(","))

get "/find" do

  @tracks = []
  @actual_tracks = []
  @query = params[:search]
  
  return erb :find unless @query

  queries = @query.split("\n")
  queries.each do |subquery|
    search = Hallon::Search.new subquery
    search.load

   if search.tracks.first 
      @tracks << search.tracks.first 
      @actual_tracks << search.tracks.first 
    else
      @tracks << subquery
    end
  end

  @track_ids = @actual_tracks.map {|track| 
    track.to_str.gsub("spotify:track:","")
  }.join(",")

  erb :find
end
