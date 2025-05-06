class AuthService
  def self.register(decoded_token, token)
    auth0_id = decoded_token.token[0]["sub"]

    existing_player = PlayerRepository.find_by_auth0_id(auth0_id)
    if existing_player && existing_player.deleted == true
      existing_player.update(deleted: false)
      return { success: true, status: :created, player: existing_player }
    end
    return { success: false, status: :conflict, message: "Player already exists" } if existing_player

    user_info = fetch_user_info(token)

    Rails.logger.info(user_info)

    name = user_info["nickname"]
    profile_picture_url = user_info["picture"]

    player = PlayerRepository.create(
      auth0_id: auth0_id,
      name: name,
      profile_picture_url: profile_picture_url,
      ranking: 0,
      preferred_cue: nil
    )

    if player.persisted?
      { success: true, status: :created, player: player }
    else
      { success: false, status: :bad_request, errors: player.errors.full_messages }
    end
  end

  def self.fetch_user_info(token)
    uri = URI("https://#{ENV["AUTH0_DOMAIN"]}/userinfo")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{token}"
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    else
      raise "Failed to fetch user info"
    end
  end

  def self.exchange_code_for_token(code)
    uri = URI("https://#{ENV['AUTH0_DOMAIN']}/oauth/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    headers = { 'Content-Type': "application/json" }
    body = {
      grant_type: "authorization_code",
      client_id: ENV["AUTH0_CLIENT_ID"],
      client_secret: ENV["AUTH0_CLIENT_SECRET"],
      code: code,
      redirect_uri: ENV["ROOT_URL"] + "/api/auth/callback"
    }

    response = http.post(uri.path, body.to_json, headers)
    JSON.parse(response.body)
  end

  def self.check_user_registered(decoded_token)
    if decoded_token.nil?
      return false
    end
    auth0_id = decoded_token.token[0]["sub"]
    player = PlayerRepository.find_by_auth0_id(auth0_id)
    return false if player.nil?
    if player.deleted == true
      Rails.logger.info("deleted!!!!")
      return false
    end
    true
  end
end
