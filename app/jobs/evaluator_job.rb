# frozen_string_literal: true

class EvaluatorJob
  def execute(queue, engine, tagger)
    # pull response from the queue
    job = queue.fetch
    return if job.nil?

    # get response text and exercise text
    response_text = job.response_text
    exercise_text = job.exercise_text

    # evaluating using given engine
    results = engine.evaluate(exercise_text, response_text)

    # generating taggings
    tagger.generate_taggings job, results

    # acknowledge the queue
    queue.ack(job)
  end
end
