class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  # importmap の変更時に HTML キャッシュを自動更新する
  stale_when_importmap_changes

  # ERB ビュー内でも current_user と logged_in? を使えるように公開する
  helper_method :current_user, :logged_in?

  private

  # セッションの user_id からログイン中ユーザーを取得する（未ログイン時は nil）
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  # ログイン済みかどうかを返す
  def logged_in?
    current_user.present?
  end

  # 未ログイン状態でアクセスされた場合、トップ画面へ誘導する共通フィルタ
  def require_login
    return if logged_in?

    redirect_to root_path, alert: "先にトップ画面でニックネーム／班名を入力してください"
  end
end
