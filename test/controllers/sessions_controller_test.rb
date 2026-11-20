require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "新しいニックネームでログインするとユーザーが増えトップへリダイレクトされること" do
    assert_difference("User.count", 1) do
      post session_url, params: { name: "新しい3班" }
    end

    assert_redirected_to root_url
    assert_equal User.find_by!(name: "新しい3班").id, session[:user_id]
    follow_redirect!
    assert_match "新しい3班", response.body
  end

  test "既存のニックネームでログインすると重複作成されず既存ユーザーでログインできること" do
    assert_no_difference("User.count") do
      post session_url, params: { name: users(:one).name }
    end

    assert_redirected_to root_url
    assert_equal users(:one).id, session[:user_id]
  end

  test "別のニックネームで再ログインするとセッションのユーザーIDが切り替わること" do
    post session_url, params: { name: users(:one).name }
    assert_equal users(:one).id, session[:user_id]

    post session_url, params: { name: users(:two).name }
    assert_redirected_to root_url
    assert_equal users(:two).id, session[:user_id]
  end

  test "空欄で送信しても500エラーにならずトップ画面へ戻されること" do
    assert_no_difference("User.count") do
      post session_url, params: { name: "   " }
    end

    assert_redirected_to root_url
    assert_not_nil flash[:alert]
  end

  test "ログアウトするとセッションが破棄され未ログイン状態に戻ること" do
    post session_url, params: { name: users(:one).name }
    assert_equal users(:one).id, session[:user_id]

    delete session_url
    assert_redirected_to root_url
    assert_nil session[:user_id]

    follow_redirect!
    assert_match "ニックネームまたは班名を入力してください", response.body
  end
end
