require 'sinatra/base'
require "sinatra/reloader"

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    return erb(:index)
  end

  post '/hello' do
    @name = params[:name]
    if @name.include?('<script>') || @name.include?('</script>')
      return erb(:hacker)
    end
    return erb(:hello)
  end
end
