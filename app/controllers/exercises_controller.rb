# frozen_string_literal: true

class ExercisesController < ApplicationController
  helper ExercisesHelper

  before_action :verify_privileges, except: %i[index commenced missed attempted]

  def new
    @exercise = Exercise.new
  end

  def edit
    @exercise = Exercise.find(params[:id])
    render :new
  end

  def index
    @exercises = Exercise.all
    if current_user.admin
      redirect_to drafts_exercises_url
    else
      redirect_to commenced_exercises_url
    end
  end

  def update
    exercise = Exercise.find(params[:id])

    respond_to do |format|
      if exercise.update_attributes(permit_params)
        flash[:success] = 'Exercise was successfully updated.'
        format.html { redirect_to exercises_path }
      else
        display_flash_error(exercise)
        format.html { redirect_to edit_exercise_path }
      end
    end
  end

  def create
    exercise = Exercise.new(permit_params)

    respond_to do |format|
      if exercise.save
        flash[:success] = 'Exercise was successfully created.'
        format.html { redirect_to exercises_path }
      else
        display_flash_error(exercise)
        format.html { redirect_to new_exercise_path }
      end
    end
  end

  def destroy
    respond_to do |format|
      Exercise.find(params[:id]).destroy
      flash[:success] = 'Exercise was successfully deleted.'
      format.html { redirect_to exercises_path }
    end
  end

  def commence
    conclude_time = params[:exercise][:conclude_time]
    exercise = Exercise.find(params[:id])
    display_flash_error(exercise) unless exercise.commence(conclude_time)
    redirect_to :exercises
  end

  def conclude
    Exercise.find(params[:id]).conclude
    redirect_to ongoing_exercises_path
  end

  # TODO: all the exercise getter methods should give out json if asked for

  def drafts
    filtered_exercises = Exercise.drafts
    render 'exercises/admin/exercises_pane', locals: {
      filtered_exercises: filtered_exercises, partial_name: ExercisesHelper.partial_name(:drafts)
    }
  end

  def ongoing
    filtered_exercises = Exercise.ongoing
    render 'exercises/admin/exercises_pane', locals: {
      filtered_exercises: filtered_exercises, partial_name: ExercisesHelper.partial_name(:ongoing)
    }
  end

  def concluded
    filtered_exercises = Exercise.concluded
    render 'exercises/admin/exercises_pane', locals: {
      filtered_exercises: filtered_exercises, partial_name: ExercisesHelper.partial_name(:concluded)
    }
  end

  def commenced
    filtered_exercises = Exercise.commence_for_candidate(current_user)
    render 'exercises/candidate/exercises_pane', locals: {
      filtered_exercises: filtered_exercises, partial_name: ExercisesHelper.partial_name(:commenced)
    }
  end

  def missed
    filtered_exercises = Exercise.missed_by_candidate(current_user)
    render 'exercises/candidate/exercises_pane', locals: { filtered_exercises: filtered_exercises, partial_name: ExercisesHelper.partial_name(:missed) }
  end

  def attempted
    exercises = Exercise.attempted_by_candidate(current_user)
    render 'exercises/candidate/attempted_exercises_pane', locals: { filtered_exercises: exercises }
  end

  private

  def permit_params
    params.require('exercise').permit(:title, :text, :duration, :commence_time, :conclude_time)
  end

  def display_flash_error(exercise)
    flash[:danger] = exercise.errors.messages.map do |m|
      m.join(' ').humanize
    end.join("\n")
  end
end
