class SessionsController < ApplicationController
  def create
    user = User.find_or_initialize_by(name: params[:name].to_s.strip)

    if user.save
      session[:user_id] = user.id
      redirect_to root_path, notice: "#{user.name} として参加しました"
    else
      redirect_to root_path, alert: "ニックネーム／班名を入力してください（50文字以内）"
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "ログアウトしました"
  end
end
