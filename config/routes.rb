Rails.application.routes.draw do
  # ヘルスチェック用（Render などの稼働確認で使用）
  get "up" => "rails/health#show", as: :rails_health_check

  # トップ画面（ルートパス）
  root "tops#index"

  # 簡易ログイン／ログアウト用のセッション管理
  resource :session, only: [ :create, :destroy ]

  # --- Phase 2 以降で追加予定の共通ルーティング ---
  # resources :facilities, only: [ :index, :show ] do
  #   resource :stamp_log, only: [ :create ]
  # end
  # resource :map, only: [ :show ]
  # resource :rally, only: [ :show ]
end
