class Category < ApplicationRecord
  # 対応災害タイプの許可値
  DISASTER_TYPES = [ "風水害", "震災", "土砂" ].freeze
  # 1つのカテゴリは複数の防災施設を持つ
  has_many :facilities, dependent: :destroy

  # カテゴリ名と対応災害タイプは必須
  validates :name, presence: true
  validates :disaster_type, presence: true, inclusion: { in: DISASTER_TYPES, allow_blank: true }
end
