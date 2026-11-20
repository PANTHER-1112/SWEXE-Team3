class Category < ApplicationRecord
  # 1つのカテゴリは複数の防災施設を持つ
  has_many :facilities, dependent: :destroy

  # カテゴリ名と対応災害タイプは必須
  validates :name, presence: true
  validates :disaster_type, presence: true
end
