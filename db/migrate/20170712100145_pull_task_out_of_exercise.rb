class PullTaskOutOfExercise < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :task_id, :string

    Exercise.all.each do |exercise|
      task = Task.create(title: exercise.title, text: exercise.text)
      exercise.update_attributes(task_id: task.id)
    end

    change_table(:exercises) do |e|
      e.remove :title
      e.remove :text
    end
  end
end
