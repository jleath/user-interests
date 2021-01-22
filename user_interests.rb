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
    @user_data.keys.each do |username|
      next if exclude.include?(username.to_s)
      user_url = "/users/#{username}"
      result += "<li><a href=\"#{user_url}\">#{username.capitalize}</a></li>\n"
    end
    result
  end

  def list_interests(interests)
    interests.map(&:capitalize).join(', ')
  end

  def list_stats
    interest_count = 0
    user_count = @user_data.size
    "<p>There are #{user_count} users with #{count_interests} interests.</p>"
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
  username = params[:username]
  unless @user_data.keys.include?(username.to_sym)
    redirect '/'
  end
  @title = username
  @name = username
  @email = @user_data[username.to_sym][:email]
  @interests = @user_data[username.to_sym][:interests]
  erb :user_page
end