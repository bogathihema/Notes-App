class TagsController < ApplicationController
  before_action :get_user
  def add_tag
    @tag = Tag.new
    @note = Note.find(params[:note_id])
    respond_to do |format|
			format.js
		end
  end

  def create
    @note = Note.find(params[:note_id])
    @note.tags.create(tag: params[:tag][:tag], name: @user.username)
    flash[:notice] = "Tag has created for the note successfully!"
    redirect_to user_notes_path(@user.id)
  end

  private
  def get_user
    @user = User.find(session[:user_id])
  end
end
