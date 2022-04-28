class NotesController < ApplicationController

  before_action :get_user

  def index
    all_notes, @read_notes, @update_notes, @owner_notes = [], [], [], []
    if @user.notes_permissions.present?
      shared_notes = JSON.parse @user.notes_permissions
      @read_notes = shared_notes["read"] if shared_notes["read"].present?
      @update_notes = shared_notes["update"] if shared_notes["update"].present?
      @owner_notes = shared_notes["owner"] if shared_notes["owner"].present?
      shared_notes = @read_notes + @update_notes + @owner_notes
      all_notes = shared_notes + @user.notes.pluck(:id)
      @notes = Note.find(all_notes.uniq)
    else
      @notes = @user.notes
    end
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
    @shared_permissions = {}
    @note = Note.find(params[:note_id])
    if @note.shared_users
      note_users = JSON.parse @note.shared_users
      @shared_users = User.find(note_users)
      @shared_users.each do |user|
        permissions = JSON.parse user.notes_permissions
        @shared_permissions[user.id] = "read" if permissions["read"].present? && permissions["read"].include?(@note.id)
        @shared_permissions[user.id] = "update" if permissions["update"].present? && permissions["update"].include?(@note.id)
        @shared_permissions[user.id] = "owner" if permissions["owner"].present? && permissions["owner"].include?(@note.id)
      end
    end
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
    note_permissions = JSON.parse @note_user.notes_permissions
    assigned_notes = note_permissions[params[:note_permission]]
    assigned_notes.delete(@note.id)
    note_permissions[params[:note_permission]] = assigned_notes
    if note_permissions[params[:new_permission]].present?
      note_permissions[params[:new_permission]] =   note_permissions[params[:new_permission]].push @note.id
    else
      note_permissions[params[:new_permission]] = [@note.id]
    end
    @note_user.update(notes_permissions: note_permissions.to_json)
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
    users=[]
    params["user_emails"].split(",").each do |email|
      notes, permissions =[], {}
      user = User.find_by(username: email.strip)
      if user.present?
        users.push user.id
        if user.notes_permissions.present?
          permissions = JSON.parse user.notes_permissions
        end
        if params[:permission] == "read"
          notes = permissions["read"] if permissions["read"].present?
          notes.push @note.id
          permissions["read"] = notes.uniq
        elsif (params[:permission] == "update")
          notes = permissions["update"] if permissions["update"].present?
          notes.push @note.id
          permissions["update"] = notes.uniq
        elsif (params[:permission] == "owner")
          notes = permissions["owner"] if permissions["owner"].present?
          notes.push @note.id
          permissions["owner"] = notes.uniq
        end
        user.update(notes_permissions: permissions.to_json)
      end
    end
    sh_note_users, sh_users = [], []
    if @note.shared_users.present?
      sh_note_users = (JSON.parse @note.shared_users) + users
    else
      sh_note_users = users
    end
    if @user.shared_users.present?
      sh_users = (JSON.parse @user.shared_users) + users
    else
      sh_users = users
    end
    @note.update(shared_users: sh_note_users)
    @user.update(shared_users: sh_users)
    flash[:notice] = "Note has shared for the selected users successfully!"
    redirect_to user_notes_path(@user.id)
  end

  def destroy
    @note = Note.find(params[:id])
    if params[:remove_user_note] == "true"
      shared_user = User.find(params[:user_id])
      if @note.shared_users.present? && @user.shared_users.present?
        shared_users = (JSON.parse @note.shared_users) + (JSON.parse @user.shared_users)
        shared_users.uniq.each do |user|
          update_notes = {}
          usr = User.find(user)
          notes = JSON.parse usr.notes_permissions
          if notes["read"].present? && notes["read"].include?(@note.id)
            update_notes["read"] = notes["read"] - [@note.id]
          elsif notes["update"].present? && notes["update"].include?(@note.id)
            update_notes["update"] = notes["update"] - [@note.id]
          elsif notes["owner"].present? && notes["owner"].include?(@note.id)
            update_notes["owner"] = notes["owner"] - [@note.id]
          else
          end
          usr.update(notes_permissions: update_notes.to_json)
        end
      end

    else
      User.all.each do |user|
        update_notes = {}
        if user.notes_permissions.present?
          notes = JSON.parse user.notes_permissions
          if notes["read"].present? && notes["read"].include?(@note.id)
            update_notes["read"] = notes["read"] - [@note.id]
          elsif notes["update"].present? && notes["update"].include?(@note.id)
            update_notes["update"] = notes["update"] - [@note.id]
          elsif notes["owner"].present? && notes["owner"].include?(@note.id)
            update_notes["owner"] = notes["owner"] - [@note.id]
          else
          end
          user.update(notes_permissions: update_notes.to_json)
        end
      end
      @note.destroy if @note.present?
      flash[:notice] = "Note deleted successfully!"
      redirect_to user_notes_path(@user.id)
    end
  end

  private
    def get_user
      @user = User.find(session[:user_id])
    end

end
