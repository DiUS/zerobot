require 'yajl'

class GithubUser

  attr_reader :token

  def initialize token
    @token = token
  end

  def login
    user['login']
  end

  def email
    user['email']
  end 
  
  def avatar_url
    user['avatar_url']
  end

  def user_repos
    Yajl.load(RestClient.get("https://api.github.com/user/repos", :params => {:access_token => @token, :type => 'owner'}))
  end

  def org_repos
    orgs.collect do |org|
      Yajl.load(RestClient.get("https://api.github.com/orgs/#{org['login']}/repos", :params => {:access_token => @token}))
    end.flatten
  end

  def orgs
    @orgs ||= Yajl.load(RestClient.get("https://api.github.com/user/orgs", :params => {:access_token => @token}))
  end


  private

  def user
    @user ||= Yajl.load(RestClient.get("https://api.github.com/user", :params => {:access_token => @token}))
  end

end
