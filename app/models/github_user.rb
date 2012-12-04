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
    get_repos.collect { |r| r['name'] }
  end
  private

  def get_user
    @user_info ||= Yajl.load(RestClient.get("https://api.github.com/user", :params => {:access_token => @token}))
  end

  def get_repos
    @repo_info ||= Yajl.load(RestClient.get("https://api.github.com/user/repos", :params => {:access_token => @token}))
  end
end
