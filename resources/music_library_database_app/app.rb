# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  post '/submit' do
    album = Album.new
    album.title = params[:title]
    album.release_year = params[:release_year]
    album.artist_id = params[:artist_id]
    repo = AlbumRepository.new
    repo.create(album)
    return erb(:submitted_ok)
  end

  get '/artists' do
    repo = ArtistRepository.new
    @artists = repo.all
    return erb(:artists)
  end

  get '/artists/:id' do
    id = params['id']
    repo = ArtistRepository.new
    artist = repo.find(id)
    @name = artist.name
    @genre = artist.genre
    return erb(:artist)
  end

  get '/artist/new' do
    return erb(:artist_new)
  end

  post '/artists' do
    artist = Artist.new
    artist.name = params[:name]
    artist.genre = params[:genre]
    repo = ArtistRepository.new
    repo.create(artist)
    return erb(:submitted_ok)
  end

  get '/album/new' do
    art_repo = ArtistRepository.new
    @artists = art_repo.all
    return erb(:album_new)
  end
  
  get '/albums/:id' do
    id = params['id']
    repo = AlbumRepository.new
    album = repo.find(id)
    @title = album.title
    @release_year = album.release_year
    artist_id = album.artist_id
    repo = ArtistRepository.new
    @artist = repo.find(artist_id).name
    return erb(:album)
  end

  get '/albums' do
    alb_repo = AlbumRepository.new
    @albums = alb_repo.all
    return erb(:albums)
  end
end