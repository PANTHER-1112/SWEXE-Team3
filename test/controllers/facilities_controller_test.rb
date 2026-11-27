require "test_helper"

class FacilitiesControllerTest < ActionDispatch::IntegrationTest
  test "未ログインでも施設一覧が正常に表示されること" do
    get facilities_url

    assert_response :success
    assert_match facilities(:one).name, response.body
    assert_match facilities(:two).name, response.body
    assert_no_match "スタンプ獲得済み", response.body
  end

  test "ログイン時は施設一覧で獲得済み施設が判定されること" do
    post session_url, params: { name: users(:one).name }
    get facilities_url

    assert_response :success
    assert_match "スタンプ獲得済み", response.body
  end

  test "未ログインでも施設詳細が正常に表示されること" do
    get facility_url(facilities(:one))

    assert_response :success
    assert_match facilities(:one).name, response.body
    assert_match facilities(:one).description, response.body
    assert_match "トップ画面からニックネームを入力してください", response.body
  end

  test "ログイン時にスタンプ獲得済みの施設詳細で獲得済み表示になること" do
    post session_url, params: { name: users(:one).name }
    get facility_url(facilities(:one))

    assert_response :success
    assert_match "ステータス：スタンプ獲得済み", response.body
  end

  test "ログイン時に未獲得の施設詳細で未獲得表示になること" do
    post session_url, params: { name: users(:one).name }
    get facility_url(facilities(:two))

    assert_response :success
    assert_match "ステータス：未獲得", response.body
  end

  test "存在しない施設IDにアクセスすると404になること" do
    get facility_url(id: 999_999)

    assert_response :not_found
  end
end
