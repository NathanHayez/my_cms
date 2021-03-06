
require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "redcarpet"

configure do
  enable :sessions
  set :session_secret, 'super secret'
end



root = File.expand_path("..", __FILE__)

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  when ".md"
    render_markdown(content) 
  end
end

get "/" do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do
  @file_path = root + "/data/" + params[:filename]
  @file_name = params[:filename]
  

  if File.exist?(@file_path)
    load_file_content(@file_path)
  else
    session[:message] = "#{@file_name} does not exist"
    redirect '/'
  end
end

# bring user to file editing section
get "/:filename/edit" do
  @file = params[:filename]
  @file_path = root + '/data/' + @file
  @content = File.read(@file_path)

  erb :edit
end

# apply changes made by user, to the file
post "/:filename/edit" do
  @file = params[:filename]
  @file_path = root + '/data/' + @file
  @edited_content = params[:edited_content]
  File.write(@file_path, @edited_content)
  session[:message] = "#{@file} has been updated."

  redirect '/'
end







