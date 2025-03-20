require "net/http"
require "json"

class RegistrationsController < Devise::RegistrationsController
  def new
    build_resource({})
    resource.build_role unless resource.role.present?
    resource.teams.build if resource.teams.empty?
    super
  end

  def create
=begin
    recaptcha_token = params[:recaptcha_token]
    unless verify_recaptcha(recaptcha_token)
      flash.now[:alert] = "reCAPTCHA 認証に失敗しました"
      render :new and return
    end
=end

    build_resource(sign_up_params)
    resource.build_role(role_params) unless resource.role.present?
    resource.teams.build(teams_params) if resource.teams.empty?

    if resource.save
      if resource.persisted? && resource.sns_credentials.empty?
        sign_up(resource_name, resource)
      end
      flash[:notice] = "登録が完了しました。メンバー管理ページにてステータスを更新してください。"
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      flash.now[:alert] = "登録に失敗しました。"
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def create_athlete
    recaptcha_token = params[:recaptcha_token]
    unless verify_recaptcha(recaptcha_token)
      redirect_to root_path, alert: "reCAPTCHA 認証に失敗しました。"
      return
    end

    @team = Team.find_by(invitation_token: params[:invitation_token])
    unless @team
      redirect_to root_path, alert: "無効な招待リンクです。"
      return
    end

    @user = build_resource(sign_up_params)
    @user.teams << @team # チームに紐付ける

    if @user.save
      # 招待ステータスをpendingに更新
      invitation = TeamInvitation.find_by(user: resource, team: @team)
      invitation&.update!(status: :pending)

      sign_up(resource_name, @user)
      redirect_to root_path, notice: "選手登録を申請しました。"
    else
      flash.now[:alert] = "選手登録の申請に失敗しました。"
      render "teams/invite"
    end
  end

  def complete_registration
    @user = current_user
    @user.build_role unless @user.role.present?
    @user.teams.build if @user.teams.empty?
  end

  def update_registration
    @user = current_user
    if @user.update(user_params)
      redirect_to root_path, notice: "登録が完了しました。"
    else
      flash.now[:alert] = "登録内容を保存できませんでした。"
      render :complete_registration
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :first_name, :last_name, role_attributes: [ :role ]
    )
  end

  def role_params
    params.require(:user).require(:role_attributes).permit(:role)
  end

  def teams_params
    params.require(:user).require(:teams_attributes).permit(:team_name)
  end

  def user_params
    params.require(:user).permit(
      role_attributes: [ :role ],
      teams_attributes: [ :team_name ]
    )
  end

  def verify_recaptcha(token)
    secret_key = Rails.application.credentials.dig(:recaptcha, :secret_key)
    uri = URI("https://www.google.com/recaptcha/api/siteverify")
    response = Net::HTTP.post_form(uri, {
      "secret" => secret_key,
      "response" => token
    })
    json = JSON.parse(response.body)
    json["success"] && json["score"].to_f > 0.5 # スコアが0.5以上ならOK
  end

  def after_sign_up_path_for(resource)
    root_path # 例: root_path や dashboard_path など
  end
end
