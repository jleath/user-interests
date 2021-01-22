require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "yaml"

before do
  @user_data = YAML.load_file('./data/users.yaml')
rescue
  @user_data = nil
end

not_found do
  redirect "/"
end

helpers do
  def list_users(exclude = [])
    result = ''
    @user_data.keys.sort.each do |username|
      next if exclude.include?(username)
      user_url = "/users/#{username}"
      result += "<li><a href=\"#{user_url}\">#{username.capitalize}</a></li>"
    end
    result
  end

  def list_interests(interests)
    interests.map(&:capitalize).join(', ')
  end

  def list_stats
    "<p>There are #{@user_data.size} users with #{count_interests} interests.</p>"
  end
end

def count_interests
  @user_data.values.map { |info| info[:interests] }.flatten.uniq.size
end

get "/" do
  @title = "User Interests"
  erb :home
end

get "/users/:username" do
  @name = params[:username].to_sym
  redirect "/" unless @user_data.keys.include?(@name)
  @title = @name
  @email = @user_data[@name][:email]
  @interests = @user_data[@name][:interests]
  erb :user_page
end