# frozen_string_literal: true

require 'after_the_deadline'

class EvaluationEngine
  def evaluate(exercise, response)
    dict = create_dict exercise
    AfterTheDeadline(dict, nil)
    AfterTheDeadline.check response
  end

  def create_dict(exercise)
    exercise.split(' ')
  end
end
