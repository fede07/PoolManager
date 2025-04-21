class AuthService
  def self.register(decoded_token, token)
    auth0_id = decoded_token.token[0]["sub"]

    existing_player = PlayerRepository.find_by_auth0_id(auth0_id)
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
end
