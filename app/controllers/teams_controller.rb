class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_coach, only: [:generate_invitation, :athletes]
  
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
    @user = User.new
    render "teams/invite"
  end

  def athletes
    @team = current_user.teams.find(params[:id]) # ログイン中のcoachのチーム
    @athletes = @team.team_invitations.includes(:user).order(:status) # 招待状況を取得
  end

  def show
    @team = Team.find(params[:id])
    @athletes = @team.team_invitations.includes(:user) # 必要に応じて変更
  end
  
  private

  def authorize_coach
    unless current_user.role&.coach?
      redirect_to root_path, alert: "権限がありません。"
    end
  end
end
  