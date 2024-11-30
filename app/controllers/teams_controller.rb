class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_coach, only: [:generate_invitation]
  
  def generate_invitation
    @team = current_user.teams.find(params[:id]) # 現在ログイン中のcoachのチーム
    @team.update(invitation_token: SecureRandom.hex(10)) # 招待トークンを生成
    redirect_to team_path(@team), notice: "招待URLが生成されました: #{invite_team_url(@team.invitation_token)}"
  end
  
  def invite
    @team = Team.find_by(invitation_token: params[:invitation_token])
    unless @team
      redirect_to root_path, alert: "無効な招待リンクです。"
      return
    end

    # 招待リンクを受け取った選手向けの登録画面を表示
    render "teams/invite"
  end
  
  private

  def authorize_coach
    redirect_to root_path, alert: "権限がありません。" unless current_user.role.coach?
  end
end
  