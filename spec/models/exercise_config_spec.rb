require 'rails_helper'

describe ExerciseConfig do
  describe 'validations ' do
    it { should validate_presence_of(:exercise_id) }

    it { should validate_numericality_of(:duration).is_greater_than_or_equal_to(0) }

    it 'validate if commence time and conclude time is nil' do
      task = Task.create(title: 'exercise title', text: 'exercise text')
      exercise = task.exercises.create
      config = ExerciseConfig.new(duration: 86_400, exercise_id: exercise.id)
      expect(config.save).to be true
    end

    it 'validate if commence time is nil and conclude time is given' do
      task = Task.create(title: 'exercise title', text: 'exercise text')
      exercise = task.exercises.create
      config = ExerciseConfig.new(duration: 86_400, conclude_time: Time.current, exercise_id: exercise.id)
      expect(config.save).to be true
    end

    it 'validate if commence time present and conclude time past time with commence time' do
      current_time = Time.current
      past_time = current_time - 4.days
      task = Task.create(title: 'exercise title', text: 'exercise text')
      exercise = task.exercises.create
      config = ExerciseConfig.new(duration: 86_400, commence_time: current_time, conclude_time: past_time, exercise_id: exercise.id)
      expect(config.save).to be false
      expect(config.errors.full_messages).to include('Conclude time must be a future time...')
    end

    it 'validate for conclude time present time' do
      current_time = Time.current
      past_time = current_time - 4.days
      task = Task.create(title: 'exercise title', text: 'exercise text')
      exercise = task.exercises.create
      config = ExerciseConfig.new(duration: 86_400, commence_time: past_time, conclude_time: current_time, exercise_id: exercise.id)
      expect(config.save).to be true
    end
  end
end
