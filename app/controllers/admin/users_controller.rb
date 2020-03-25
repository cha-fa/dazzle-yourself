class Admin::UsersController < Admin::BaseController

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
      if @user.update(first_name: params[:first_name], last_name: params[:last_name], email: params[:email])
        flash[:success] = "Les informations ont été modifiées"
        redirect_to admin_user_path
      else
        flash[:alert] = "Les informations n'ont pas été modifiées"
        redirect_to admin_user_path
      end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path
    flash.alert = "Le participant #{params[:id]} a bien été supprimé !"
  end

end