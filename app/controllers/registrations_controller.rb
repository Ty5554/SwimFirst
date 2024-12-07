class RegistrationsController < Devise::RegistrationsController
  def new
    build_resource({})
    resource.build_role unless resource.role.present?
    resource.teams.build if resource.teams.empty?
    super
  end

  def create
    build_resource(sign_up_params)
    resource.build_role(role_params) unless resource.role.present?
    resource.teams.build(teams_params) if resource.teams.empty?

    if resource.save
      sign_up(resource_name, resource)
      flash[:notice] = "登録が完了しました。"
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      flash.now[:alert] = "登録に失敗しました。"
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def create_athlete
    @team = Team.find_by(invitation_token: params[:invitation_token])
    unless @team
      redirect_to root_path, alert: "無効な招待リンクです。"
      return
    end

    @user = build_resource(sign_up_params)
    @user.teams << @team # チームに紐付ける

    if @user.save
      # 招待ステータスをapprovedに更新
      invitation = TeamInvitation.find_by(user: resource, team: @team)
      invitation&.update!(status: :pending)

      sign_up(resource_name, @user)
      redirect_to root_path, notice: "選手登録を申請しました。"
    else
      Rails.logger.error(@user.errors.full_messages.join(", "))
      @resource = @user
      render "teams/invite", alert: "選手登録の申請に失敗しました。"
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
end
