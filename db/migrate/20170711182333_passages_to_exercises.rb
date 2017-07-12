class PassagesToExercises < ActiveRecord::Migration[5.1]
  def change
    rename_table :passages, :exercises
    rename_column :responses, :passage_id, :exercise_id
    rename_column :responses_trackings, :passage_id, :exercise_id
  end
end
