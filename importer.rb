# require loads in library so you can use it.
# You can install ruby libraries using the terminal and the command
# `gem install [name of library]`
# You can learn about what libraries there are by cruising
# http://rubygems.org/.
require "sinatra"
require "hallon"

# This line reads in the api key file that is in the same directory as this file.
# IO is a class that lets you read and write files.
api_key = IO.read('./spotify_appkey.key')
# Here we pass in the key we just loaded up to the Hallon library and ask it to initialize
# a session for us.
session = Hallon::Session.initialize api_key
# Here we actually log the session in. Methods that in ! usually mean that they modify the object
# directly as opposed to returning a copy.
session.login!(*IO.read('./creds.txt').split(","))

# This is some sinatra code. Sinata is a DSL (domain specific language) that makes writing little web services easy.
# This line says, when you receive an HTTP "GET" request at the url http://[the host name]/[some query] store the query
# into a holder object called params so you can read it later. 
# Learn more here http://www.sinatrarb.com/
get "/find" do

  # set @tracks to an empty array initially
  @tracks = []
  @actual_tracks = []

  # Here I'm just getting the query out of the params holder object. The :query is a special kind of label called
  # a symbol think of it as a way to tag a piece of data in the params holder object.
  @query = params[:search]
  
  return erb :find unless @query

  queries = @query.split("\n")

  # Here we ask Hallon to create a new Seach object and then load that search by actually talking to Spotify's web
  # server.
  queries.each do |subquery|
    search = Hallon::Search.new subquery
    search.load
    # Here I iterate over all the tracks in the loaded search. In ruby you can call `each` on any collection object
    # and then `do` the lines below for each object in the collection. Here we are creating a big long string that
    # concatenates the results and shows each result's track, album and artist. Note += means make the out variable
    # equal to what it is plus what follows, which is a shortcut for out = out + "whatever".
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