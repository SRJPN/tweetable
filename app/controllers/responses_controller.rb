# frozen_string_literal: true

class ResponsesController < ApplicationController
  before_action :set_response, only: [:show]

  def index
    exercise = Exercise.find(params[:exercise_id])
    responses = exercise.responses.order('created_at DESC')
    partial = current_user.admin ? 'response_evaluation' : 'response'
    render 'index', locals: { responses: responses, exercise: exercise, partial: partial }
  end

  def show; end

  def new
    exercise = Exercise.find(params[:exercise_id])
    user = current_user
    duration = ResponsesTracking.remaining_time(exercise.id, user.id)
    render :new, locals: { exercise: exercise, response: exercise.responses.new, user: user, remaining_time: duration }
  rescue
    redirect_to exercises_path
  end

  def create
    exercise = Exercise.find(params[:exercise_id])
    user = current_user
    remaining_time = ResponsesTracking.remaining_time(exercise.id, user.id)

    @response = Response.new(response_params)
    respond_to do |format|
      if remaining_time <= 0
        flash[:danger] = 'Sorry, Your response submission time is expired!'
        format.html { redirect_to exercises_path }
      elsif @response.save
        ResponsesTracking.update_end_time(params[:exercise_id], current_user.id)
        flash[:success] = 'Your response was successfully recorded.'
        format.html { redirect_to exercises_path }
      else
        flash[:danger] = 'Sorry, Your response was invalid!'
        format.html { redirect_to new_exercise_response_path(Exercise.find(params[:exercise_id])) }
      end
    end
  end

  private

  def set_response
    @response = Response.find(params[:id])
  end

  def response_params
    params.permit(:user_id, :exercise_id, :text)
  end
end
