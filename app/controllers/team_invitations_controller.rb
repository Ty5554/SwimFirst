class TeamInvitationsController < ApplicationController
=begin
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
  
  private
  
  def team_invitation_params
    params.require(:team_invitation).permit(:team_id)
  end
=end
end
  