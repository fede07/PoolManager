require "test_helper"
require "mocha/minitest"

class MatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    valid_start_time = Time.now + 1.day

    @valid_params = {
      player1_id: 1,
      player2_id: 2,
      start_time: (valid_start_time).to_s,
      end_time: (valid_start_time + 90.minutes).to_s
    }

    @valid_params_double_booking = {
      player1_id: 1,
      player2_id: 2,
      start_time: (valid_start_time + 15.minutes).to_s,
      end_time: (valid_start_time + 105.minutes).to_s
    }

    @invalid_params_missing_player1 = {
      player1_id: 5,
      player2_id: 2,
      start_time: (valid_start_time + 1.day).to_s,
      end_time: (valid_start_time + 1.day + 90.minutes).to_s
    }

    @invalid_params_missing_player2 = {
      player1_id: 1,
      player2_id: 5,
      start_time: (valid_start_time + 1.day).to_s,
      end_time: (valid_start_time + 1.day + 90.minutes).to_s
    }

    @invalid_params_invalid_time = {
      player1_id: 1,
      player2_id: 2,
      start_time: "invalid-time"
    }

    @invalid_params_missing_player = {
      player1_id: 1,
      start_time: (valid_start_time + 1.day).to_s,
      end_time: (valid_start_time + 1.day + 90.minutes).to_s
    }

    @list_of_players = [
      { id: 1, name: "Player 1" },
      { id: 2, name: "Player 2" }
    ]

    @list_of_matches = [
      { id: 1, player1: "player1", player2: "player2", start_time: DateTime.now, end_time: DateTime.now + 1.hour }
    ]

    Api::MatchesController.any_instance.stubs(:authorize).returns(true)

    PlayerRepository.stubs(:find_by_id).with(1).returns({ id: 1, name: "Player 1" })
    PlayerRepository.stubs(:find_by_id).with(2).returns({ id: 2, name: "Player 2" })

    PlayerRepository.stubs(:find_by_id).with(5).returns(nil)

    MatchRepository.stubs(:conflicting_matches).with(1, anything, anything).returns([])
    MatchRepository.stubs(:conflicting_matches).with(2, anything, anything).returns([])
    MatchRepository.stubs(:conflicting_matches).with(5, anything, anything).returns([])
  end

  test "should list all matches" do
    MatchRepository.stubs(:all_matches).returns(@list_of_players)
    get "/api/matches"
    assert_response :success
  end

  test "should create a match successfully with valid parameters" do
    MatchRepository.stubs(:create).with(@valid_params).returns({ id: 1, success: true })
    MatchRepository.stubs(:conflicting_matches).with(1, anything, anything).returns(false)

    result = MatchService.create_match(@valid_params)

    assert result[:success], "Expected success to be true"
    assert_equal :created, result[:status], "Expected status to be :created"
  end

  test "should return conflict for double booking" do
    MatchService.create_match(@valid_params)
    result = MatchService.create_match(@valid_params_double_booking)

    assert_equal :conflict, result[:status], "Expected status to be :conflict"
  end

  test "should return not_found if Player 1 does not exist" do
    result = MatchService.create_match(@invalid_params_missing_player1)
    assert_equal :not_found, result[:status], "Expected status to be :not_found"
  end

  test "should return not_found if Player 2 does not exist" do
    result = MatchService.create_match(@invalid_params_missing_player2)
    assert_equal :not_found, result[:status], "Expected status to be :not_found"
  end

  test "should handle missing required parameters" do
    result = MatchService.create_match(@invalid_params_missing_player)
    assert_equal :bad_request, result[:status], "Expected status to be :bad_request"
    assert_equal "Missing player 2", result[:message], "Expected message to be Missing required parameters"
  end

  test "should return bad_request if start time is invalid" do
    result = MatchService.create_match(@invalid_params_invalid_time)
    assert_equal :bad_request, result[:status], "Expected status to be :bad_request"
    assert_equal "Invalid start time", result[:message], "Expected message to be Invalid time"
  end

  test "should fetch matches filtered by date" do
    filtered_date = Date.today
    MatchRepository.stubs(:filtered_matches)
                   .with(date: filtered_date, status: nil, player_id: nil)
                   .returns(@list_of_matches)
    get "/api/matches?date=#{filtered_date}"
    assert_response :success
  end

  test "should prevent match deletion if it has already started" do
    match_mock = mock("Match")
    match_mock.stubs(:id).returns(1)
    match_mock.stubs(:player1_id).returns(1)
    match_mock.stubs(:player2_id).returns(2)
    match_mock.stubs(:start_time).returns(Time.now - 1.day)
    match_mock.stubs(:end_time).returns(Time.now - 1.day + 10.minutes)

    MatchRepository.stubs(:get_match).with(anything).returns(match_mock)
    response = MatchService.delete_match(1)
    assert_equal :conflict, response[:status], "Expected status to be :conflict"
  end
end
