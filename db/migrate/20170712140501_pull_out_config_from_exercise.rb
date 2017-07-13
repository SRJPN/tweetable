class PullOutConfigFromExercise < ActiveRecord::Migration[5.1]
  def change
    Exercise.all.each do |exercise|
      ExerciseConfig.create(exercise_id: exercise.id, duration: exercise.duration, conclude_time: exercise.conclude_time, commence_time: exercise.commence_time)
    end

    change_table(:exercises) do |e|
      e.remove :duration
      e.remove :commence_time
      e.remove :conclude_time
    end
  end
end
