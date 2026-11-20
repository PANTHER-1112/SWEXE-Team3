class Facility < ApplicationRecord
  belongs_to :category
  has_many :stamp_logs, dependent: :destroy
  # 施設名と説明文は必須
  validates :name, presence: true
  validates :description, presence: true
  # 静的マップ画像上の相対座標（0.0%〜100.0% の範囲に制限）
  validates :map_x, presence: true, numericality: {
    greater_than_or_equal_to: 0.0,
    less_than_or_equal_to: 100.0
  }
  validates :map_y, presence: true, numericality: {
    greater_than_or_equal_to: 0.0,
    less_than_or_equal_to: 100.0
  }
end
