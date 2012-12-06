require 'yajl'

class GithubUser

  attr_reader :token

  def initialize token
    @token = token
  end

  def login
    get_user['login']
  end

  def avatar_url
    get_user['avatar_url']
  end

  def repos
    (get_user_repos + get_org_repos).collect { |r| { :name => r['name'], :html_url => r['html_url'] }}.sort_by{ |r| r[:name].downcase }
  end

  def get_org_repos
    get_user_orgs.collect do |org|
      Yajl.load(RestClient.get("https://api.github.com/orgs/#{org['login']}/repos", :params => {:access_token => @token}))
    end.flatten
  end
  private

  def get_user
    @user_info ||= Yajl.load(RestClient.get("https://api.github.com/user", :params => {:access_token => @token}))
  end

  def get_user_orgs
    @user_orgs ||= Yajl.load(RestClient.get("https://api.github.com/user/orgs", :params => {:access_token => @token}))
  end

  def get_user_repos
    @repo_info ||= Yajl.load(RestClient.get("https://api.github.com/user/repos", :params => {:access_token => @token}))
  end

end
