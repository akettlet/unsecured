require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_artists_table
  seed_sql = File.read('spec/seeds/artists_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

describe Application do
  before(:each) do 
    reset_artists_table
    reset_albums_table
  end
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "POST /submit" do
    it 'a form to create a new album' do
      response = get('/album/new')

      expect(response.status).to eq(200)
      expect(response.body).to include('2 - ABBA - Pop')
      expect(response.body).to include(' <form action="/submit" method="POST">')
      expect(response.body).to include('<input type="text" name="title">')
      expect(response.body).to include('<input type="text" name="release_year">')
      expect(response.body).to include('<input type="text" name="artist_id">')
      expect(response.body).to include('<input type="submit" value="Submit the form">')
    end

    it 'creates a new album' do
      response = post('/submit', title: "Voyage", release_year: "2022", artist_id: 2)
      expect(response.status).to eq(200)
      repo = AlbumRepository.new
      results = repo.all
      expect(results.last.title).to eq "Voyage"
      expect(results.last.release_year).to eq "2022"
      expect(results.last.artist_id).to eq 2
      expect(response.body).to include('Form submitted OK')

    end
  end

  context "GET /artists" do
    it 'returns index of artists' do
      response = get('/artists')

      expect(response.status).to eq(200)
      expect(response.body).to include('Title: <a href="/artists/1">Pixies</a>')
      expect(response.body).to include('Genre: Rock')
      expect(response.body).to include('Title: <a href="/artists/2">ABBA</a>')
      expect(response.body).to include('Genre: Pop')
      expect(response.body).to include('Title: <a href="/artists/3">Taylor Swift</a>')
      expect(response.body).to include('Genre: Pop')
      expect(response.body).to include('Title: <a href="/artists/4">Nina Simone</a>')
      expect(response.body).to include('Genre: Pop')
    end
  end

  context "GET /artists/:id" do
    it 'returns artist 1' do
      response = get('/artists/1')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Pixies</h1>')
      expect(response.body).to include('<div>Genre: Rock')
    end

    it 'returns artist 2' do
      response = get('/artists/2')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>ABBA</h1>')
      expect(response.body).to include('<div>Genre: Pop')
    end

    it 'returns artist 4' do
      response = get('/artists/4')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Nina Simone</h1>')
      expect(response.body).to include('<div>Genre: Pop')
    end
  end

  context "GET /artist/new" do
    it 'returns a web page to create a new artist' do
      response = get('/artist/new')

      expect(response.status).to eq(200)
      expect(response.body).to include('<form action="/artists" method="POST">')
      expect(response.body).to include('<input type="text" name="name">')
      expect(response.body).to include('<input type="text" name="genre">')
    end
  end

  context "POST /artists" do
    it 'creates a new artist' do
      response = post('/artists', name: 'Wild nothing', genre: 'Indie')

      expect(response.status).to eq(200)
      expect(response.body).to include('Form submitted OK')
      # expect(response.body).to eq(expected_response)

      response = get('/artists')
      expected_response = 'Pixies, ABBA, Taylor Swift, Nina Simone, Wild nothing'
      expect(response.status).to eq(200)
      expect(response.body).to include('Wild nothing')
    end
  end

  context "GET /albums/:id" do
    it 'get album 1' do
      response = get('/albums/1')
      expect(response.status).to eq(200)
      expect(response.body).to include("<h1>Doolittle</h1>")
      expect(response.body).to include("Release year: 1989")
      expect(response.body).to include("Artist: Pixies")
    end

    it 'get album 2' do
      response = get('/albums/2')
      expect(response.status).to eq(200)
      expect(response.body).to include("<h1>Surfer Rosa</h1>")
      expect(response.body).to include("Release year: 1988")
      expect(response.body).to include("Artist: Pixies")
    end
  end

  context "GET /albums" do
    it 'get all albums' do
      response = get('/albums')
      expect(response.status).to eq(200)
      expect(response.body).to include('Title: <a href="albums/1">Doolittle</a>')
      expect(response.body).to include("Released: 1989")

      expect(response.body).to include('Title: <a href="albums/2">Surfer Rosa</a>')
      expect(response.body).to include("Released: 1988")

      expect(response.body).to include('Title: <a href="albums/3">Waterloo</a>')
      expect(response.body).to include("Released: 1974")

      expect(response.body).to include('Title: <a href="albums/12">Ring Ring</a>')
      expect(response.body).to include("Released: 1973")
    end
  end
end
