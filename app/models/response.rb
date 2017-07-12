# frozen_string_literal: true

class Response < ApplicationRecord
  after_save :notify_observer
  validates :text, presence: true
  validates_length_of :text, maximum: 140, on: :create, too_long: "Tweet length can't be more than 140 characters"
  validates :user_id, presence: true
  validates :exercise_id, presence: true

  belongs_to :exercise
  belongs_to :user
  has_many :taggings
  has_many :tags, through: :taggings
  accepts_nested_attributes_for :user, :exercise

  def notify_observer
    ResponseObserver.notify(exercise, self)
  end
end
