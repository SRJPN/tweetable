class ExerciseConfig < ApplicationRecord
  after_initialize :defaults, unless: :persisted?

  validates :exercise_id, presence: true
  validates_numericality_of :duration, greater_than_or_equal_to: 0
  validate :date_validations

  belongs_to :exercise

  DEFAULT_DURATION = 3600

  private

  def date_validations
    return if valid_commence_time?
    errors.add(:conclude_time, 'must be a future time...')
  end

  def valid_conclude_time?
    conclude_time.present? && conclude_time > commence_time
  end

  def valid_commence_time?
    return true unless commence_time.present?
    valid_conclude_time?
  end

  def defaults
    self.duration ||= DEFAULT_DURATION
  end
end
