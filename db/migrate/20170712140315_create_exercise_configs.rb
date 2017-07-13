class CreateExerciseConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :exercise_configs do |t|
      t.integer :exercise_id
      t.datetime :commence_time
      t.datetime :conclude_time
      t.integer :duration
      t.timestamps
    end
  end
end
