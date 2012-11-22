class GithubUser

  attr_reader :token

  def initialize token
    @token = token
  end

  def login
    get_user['login']
  end

  private

  def get_user
    @user_info ||= Yajl.load(RestClient.get("https://api.github.com/user", :params => {:access_token => @token}))
  end

end
