require 'yajl'

class Source::Security

  def initialize(client_id = Dupondius.config.github_client_id,
                 secret = Dupondius.config.github_secret,
                 oauth_url = 'https://github.com')
    @client_id = client_id
    @secret = secret
    @oauth_url = oauth_url
  end

  def get_token(code)
    client.auth_code.get_token(code)
  end

  def authorize
    authorize_url
  end

  private

  def state
    @state ||= Digest::SHA1.hexdigest(rand(36**8).to_s(36))
  end

  def scopes
    ['repo']
  end

  def client
    @client ||= OAuth2::Client.new(@client_id, @secret,
                                   :site          => @oauth_url,
                                   :token_url     => '/login/oauth/access_token',
                                   :authorize_url => '/login/oauth/authorize')
  end

  def authorize_url
    client.auth_code.authorize_url(
      :state        => state,
      :scope        => scopes
    )
  end
end
