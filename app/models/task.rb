class Task < ApplicationRecord
  validates :title, presence: true
  validates :text, presence: true

  has_many :exercises, dependent: :destroy
end
