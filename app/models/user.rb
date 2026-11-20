class User < ApplicationRecord
  # 1人のユーザーは複数のスタンプ獲得履歴を持つ
  has_many :stamp_logs, dependent: :destroy
  has_many :facilities, through: :stamp_logs

  # 前後の余分な空白を自動で取り除く（例：" 1班 " -> "1班"）
  normalizes :name, with: ->(name) { name.strip }

  # ニックネーム／班名は必須・重複不可・最大50文字
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
end
