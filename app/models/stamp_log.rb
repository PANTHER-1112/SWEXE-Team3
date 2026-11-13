class StampLog < ApplicationRecord
  belongs_to :user
  belongs_to :facility
  # 獲得日時は必須
  validates :visited_at, presence: true
  validates :facility_id, uniqueness: {
    scope: :user_id,
    message: "はすでにスタンプ獲得済みです"
  }
end
