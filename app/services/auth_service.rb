class AuthService
  def self.register(decoded_token)
    Rails.logger.info decoded_token
    auth0_id = decoded_token.token[0]["sub"]
    name = decoded_token.token[0]["name"] || "Anonymous"
    profile_picture_url = decoded_token.token[0]["picture"] || "empty.png"

    existing_player = PlayerRepository.find_by_auth0_id(auth0_id)
    return { success: false, status: :conflict, message: "Player already exists" } if existing_player

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
end
