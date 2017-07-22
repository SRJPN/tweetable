class Task < ApplicationRecord
  validates :title, presence: true
  validates :text, presence: true

  has_many :exercises, dependent: :destroy, inverse_of: :task
  accepts_nested_attributes_for :exercises
end
