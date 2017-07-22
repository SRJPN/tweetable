# frozen_string_literal: true

class ManualController < ApplicationController
  protect_from_forgery with: :exception

  def index
    current_user.admin ? admin_help : candidate_help
  end

  private

  def admin_help
    filename = Rails.root.join('docs', 'Manual.md').to_s
    markup_content(filename)
  end

  def candidate_help
    filename = Rails.root.join('docs', 'StudentManual.md').to_s
    markup_content(filename)
  end

  # TODO: pull the code to application layer if further other use case are there

  def markup_content(filename)
    contents = File.read(filename)
    renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer)
    @text = markdown.render(contents)
  end
end
