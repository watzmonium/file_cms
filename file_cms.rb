require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'redcarpet'

configure do
  enable :sessions
  set :session_secret, 'secret'
  #set :erb, :escape_html => true
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../tests/data", __FILE__)
  else
    File.expand_path("../public/data", __FILE__)
  end
end

before do
  @root = data_path
  @files = load_files(@root)
end

helpers do
  def load_files(root)
    os_pattern = File.join(root, "*")
    Dir.glob(os_pattern).map { |path| File.basename(path)}
  end

  def load_file_content(path, flag = false)
    content = File.read(path)
    case File.extname(path)
    when '.txt'
      headers['Content-Type'] = 'text/plain' unless flag
      content
    when '.md'
      # red carpet usage
      # this object can/should be reused and the .render call can be used with your
      # input text to get any markdown
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
      if flag 
        content
      else
        erb markdown.render(content)
      end
    end
  end

  def create_document(name, content = "")
    File.open(File.join(@root, name), "w") do |file|
      file.write(content)
    end
  end
end

get '/' do 
  erb :index, layout: :layout
end

get '/new' do
  erb :new_doc
end

post '/new' do
  doc_name = params[:doc_name]
  if doc_name.empty?
    session[:failure] = "A name is required"
    status 422
    erb :new_doc
  elsif !doc_name.match?(/\.[A-Za-z0-9]+$/)
    session[:failure] = "File must have a valid extension."
    status 422
    erb :new_doc
  else
    create_document(doc_name)
    session[:success] = "#{doc_name} created."
    redirect '/'
  end
end

post '/delete' do
  file_name = params[:file]
  File.delete(File.join(@root, file_name))
  @files.delete(file_name)
  session[:success] = "File #{file_name} successfully deleted."
  redirect '/'
end

post '/files/:file' do
  @file_name = params[:file]
  unless @files.include?(@file_name)
    session[:failure] = "#{@file_name} does not exist"
    redirect '/'
  end
  text = params['edit_text']
  path = File.join(@root, @file_name)
  File.write(path, text)
  session[:success] = "#{@file_name} updated successfully"
  redirect '/'
end

get '/files/:file' do
  @file_name = params[:file]
  unless @files.include?(@file_name)
    session[:failure] = "#{@file_name} does not exist"
    redirect '/'
  end
  path = File.join(@root, @file_name)
  @text = load_file_content(path)
end

get '/files/:file/edit' do
  @file_name = params[:file]
  unless @files.include?(@file_name)
    session[:failure] = "#{@file_name} does not exist"
    redirect '/'
  end
  path = File.join(@root, @file_name)
  @text = load_file_content(path, true)
  erb :edit_file
end

not_found do
  redirect '/'
end