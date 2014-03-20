require 'sinatra'
# Avoid stopping and starting the server while in development
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require 'v8'
require 'coffee-script'

before do
  set_title
end

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      %Q{<link href="/#{stylesheet}.css" media="screen, projection" rel="stylesheet"/>}
    end.join
  end
  
  def current?(path='/')
    (request.path==path || request.path==path+'/') ? "current" : nil
  end
  
  def set_title
    @title ||= "Predictive Recursive Descent Parser"
  end
end

get('/main.css'){ scss :main }
get('/javascripts/main.js'){ coffee :main }

get '/' do
  slim :index
end

not_found do
  slim :not_found
end

