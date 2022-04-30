class NotesController < ApplicationController

  before_action :get_user

  def index
    @user_notes = @user.notes
    shared_notes = SharedNote.where(shared_user_id: @user.id)
    @notes_ids = shared_notes.pluck(:note_id)
    @user_shared_notes = Note.all.find(@notes_ids)
  end

  def new
    @note = Note.new
  end

  def create
    @note = @user.notes.create(title: params[:note][:title], body: params[:note][:body])
    flash[:danger] = "Created note successfully!"
    redirect_to user_notes_path(@user.id)
  end

  def edit
    @note = Note.find(params[:id])
  end

  def show
    @note = Note.find(params[:id])
    @tags = @note.tags
  end

  def update
    @note = Note.find(params[:id])
    @note.update(title: params[:note][:title], body: params[:note][:body])
    flash[:notice] = "Note has updated successfully!"
    redirect_to user_notes_path(@user.id)
  end

  def edit_permissions
    # @shared_permissions = {}
    @note = Note.find(params[:note_id])
    @shared_notes = @note.shared_notes
  end

  def change_permissions
    @note = Note.find(params[:note_id])
    @note_user = User.find(params[:user_id])
    @permission = params[:permission]
    respond_to do |format|
			format.js
		end
  end

  def update_permissions
    @note = Note.find(params[:note_id])
    @note_user = User.find(params[:user])
    @note.shared_notes.where(permissions: params["note_permission"], shared_user_id: @note_user.id, user_id: @user.id).first.update(permissions: params[:new_permission])
    if params[:note_permission] == "owner"
      shared_users = @note_user.shared_notes.where(note_id: @note.id, permissions: "owner")
      if shared_users.present?
        shared_users.all.each do |sh_note|
          sh_note.update(permissions: params[:new_permission])
        end
      end
    elsif (params[:note_permission] == "update" && params[:new_permission] == "read")
      shared_users = @note_user.shared_notes.where(note_id: @note.id, permissions: "update")
      if shared_users.present?
        shared_users.all.each do |sh_note|
          sh_note.update(permissions: params[:new_permission])
        end
      end
    else
    end
    flash[:notice] = "Note permission has updated for the user: #{@note_user.username}"
    redirect_to user_note_edit_permissions_path(note_id: @note.id)
  end


  def share_note
    @note = Note.find(params[:note_id])
    respond_to do |format|
			format.js
		end
  end

  def save_sharing
    @note = Note.find(params[:note_id])
    users, non_exist_users=[],[]
    params["user_emails"].split(",").each do |email|
      user = User.find_by(username: email.strip)
      if user.present?
        @user.shared_notes.create(note_id: @note.id, shared_user_id: user.id, permissions: params[:permission])
      else
        non_exist_users.push email
      end
    end
    if non_exist_users.present?
      flash[:notice] = "Skipped sharing note to non exsting users.. #{non_exist_users}"
    else
      flash[:notice] = "Note has shared for the selected users successfully!"
    end
    redirect_to user_notes_path(@user.id)
  end

  def destroy
    @note = Note.find(params[:id])
    if params[:remove_user_note] == "true"
      shared_user = User.find(params[:user_id])
      SharedNote.where(note_id: @note.id, shared_user_id: shared_user.id).first.delete
      shared_user.shared_notes.where(note_id: @note.id).delete_all
      flash[:notice] = "Note has been removed for the user and shared users successfully!"
    else
      SharedNote.where(note_id: @note.id).delete_all
      @note.destroy if @note.present?
      flash[:notice] = "Note deleted successfully!"
    end
    redirect_to user_notes_path(@user.id)
  end

  private
    def get_user
      @user = User.find(session[:user_id])
    end

end
