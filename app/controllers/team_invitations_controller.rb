class TeamInvitationsController < ApplicationController
  def index
  end
    
  def approve
    @invitation = TeamInvitation.find(params[:id])
    if @invitation.pending?
      @invitation.update!(status: :approved)
      flash[:notice] = "Invitation approved."
    else
      flash[:alert] = "Invitation is already approved."
    end
    redirect_to team_path(@invitation.team)
  end

  def create
    @team_invitation = TeamInvitation.new(team_invitation_params)
    @team_invitation.user = current_user
    if @team_invitation.save
      redirect_to root_path, notice: "チーム参加申請が送信されました。"
    else
      render :new, alert: "申請に失敗しました。"
    end
  end

  # 招待URLを生成するアクション
  def generate_url
    # 現在のチームを取得
    @team = current_user.teams.first # コーチが所属する最初のチームを取得（必要に応じて変更）

    # チームが存在しない場合のエラーハンドリング
    unless @team
      render json: { error: "チームが見つかりませんでした。" }, status: :unprocessable_entity
      return
    end

    # チームに`invitation_token`がなければ生成
    @team.update!(invitation_token: SecureRandom.hex(10)) unless @team.invitation_token.present?

    # 招待URLを生成
    invitation_url = invite_team_url(@team.invitation_token)

    # JSONレスポンスでURLを返す
    render json: { url: invitation_url }
  rescue StandardError => e
    # エラーハンドリング
    render json: { error: e.message }, status: :unprocessable_entity
  end
  
  private
  
  def team_invitation_params
    params.require(:team_invitation).permit(:team_id)
  end
end
