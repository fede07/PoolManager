require "test_helper"
require "mocha/minitest"

class Api::PlayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_auth0_id = "auth0|12345"
    @invalid_auth0_id = "auth0|invalid"

    @existing_player = { id: 1, auth0_id: @valid_auth0_id, name: "John Doe" }
    @new_player_params = { auth0_id: @valid_auth0_id,
                           name: "Test Player",
                           profile_picture_url: "https://example.com/image.png",
                           preferred_cue: "C",
                           ranking: 0 }

    @created_player = { id: 10 }.merge(@new_player_params)
    @update_params = { name: "Updated Test Player" }

    @valid_token = "valid-token"

    Api::PlayersController.any_instance.stubs(:authorize).returns(true)
    Api::PlayersController.any_instance.stubs(:validate_permissions).returns(true)
  end

  test "should create a new player with valid params" do
    PlayerRepository.stubs(:create).with(@new_player_params).returns(@created_player)
    result = PlayerService.create_player(@new_player_params)
    assert_equal :created, result[:status], "Expected status to be created"
  end

  test "should search for existing player by name" do
    result = PlayerService.search_players("John Doe")
    player = result[:players].first
    assert_equal :ok, result[:status], "Expected status to be ok"
    assert_equal 1, result[:players].length, "Expected 1 player to be returned"
    assert_equal "John Doe", player[:name], "Expected existing player to be returned"
  end
end
