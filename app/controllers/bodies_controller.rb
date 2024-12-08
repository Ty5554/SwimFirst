class BodiesController < ApplicationController
    before_action :set_bodies, only: %i[show edit update destroy]
    before_action :authenticate_user!
    before_action :authorize_approved, only: %i[index new create edit update show edit update destroy]

    def index
      @bodies = current_user.bodies
      @all_bodies = ::Body.joins(user: :teams)
      .where(teams: { id: current_user.teams.ids })
      .distinct
    end

    def new
      @body = current_user.bodies.new
    end

    def create
      @body = current_user.bodies.new(body_params)
      if @body.save
        redirect_to bodies_path, notice: "記録が作成されました。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @body= current_user.bodies.find(params[:id])
    end

    def update
      if @body.update(body_params)
        redirect_to bodies_path, notice: "記録が更新されました。"
      else
        flash.now[:alert] = "記録の更新に失敗しました"
        render :edit, status: :unprocessable_entity
      end
    end

    def show; end

    def destroy
      @body.destroy
      redirect_to bodies_path, notice: "記録が削除されました。"
    end

    private

    def set_bodies
      @body = current_user.bodies.find(params[:id]) || []
    rescue ActiveRecord::RecordNotFound
      redirect_to bodies_path, alert: "指定された記録が見つかりませんでした。"
    end

    def body_params
      params.require(:body).permit(:height, :weight, :body_fat, :recorded_on)
    end

    def authorize_approved
      unless current_user.team_invitations.where(status: :approved).exists?
        redirect_to root_path, alert: "権限がありません。"
      end
    end
end
