require "sinatra"
require "pg"
require "pry"

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

get "/actors" do
  db_connection do |conn|
    get_actors = "SELECT name, id FROM actors ORDER BY actors.name;"
    actors_pg = conn.exec(get_actors)
     erb :'actors/index', locals: {actors_pg: actors_pg}
  end
end

get "/actors/:id" do
  db_connection do |conn|
    get_actor_details = "SELECT actors.name, cast_members.character, movies.title, movies.id
    FROM actors
    JOIN cast_members ON actors.id = cast_members.actor_id
    JOIN movies ON movies.id = cast_members.movie_id
    WHERE actors.id = '#{params[:id]}';"

    details_pg = conn.exec(get_actor_details)
    erb :'actors/show', locals: {details_pg: details_pg}
  end
end

get "/movies" do
    db_connection do |conn|
      get_movies = "SELECT movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio, movies.id
      FROM movies
      JOIN genres ON genres.id = movies.genre_id
      JOIN studios ON studios.id = movies.studio_id
      ORDER BY movies.title;"
      movies_pg = conn.exec(get_movies)
      erb :'movies/index', locals: {movies_pg: movies_pg}
    end
end

get "/movies/:id" do
  db_connection do |conn|
    get_movie_details = "SELECT genres.name AS genre, studios.name AS studio, actors.name AS actor, cast_members.character, movies.title, movies.id, actors.id AS actor_id
    FROM movies
    JOIN cast_members ON movies.id = cast_members.movie_id
    JOIN genres ON genres.id = movies.genre_id
    JOIN studios ON studios.id = movies.studio_id
    JOIN actors ON actors.id = cast_members.actor_id
    WHERE movies.id = '#{params[:id]}';"
  # binding.pry
    movie_dets_pg = conn.exec(get_movie_details)
  erb :'movies/show', locals: {movie_dets_pg: movie_dets_pg}
  end
end
