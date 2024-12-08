class ConditionsController < ApplicationController
    before_action :set_conditions, only: %i[show edit update destroy]
    before_action :authenticate_user!
    before_action :authorize_approved, only: %i[index new create edit update show edit update destroy]

    def index
      @conditions = current_user.conditions
    end

    def new
      @condition = current_user.conditions.new
    end

    def create
      @condition = current_user.conditions.new(condition_params)
      if @condition.save
        redirect_to conditions_path, notice: "記録が作成されました。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @condition= current_user.conditions.find(params[:id])
    end

    def update
      if @condition.update(condition_params)
        redirect_to conditions_path, notice: "記録が更新されました。"
      else
        flash.now[:alert] = "記録の更新に失敗しました"
        render :edit, status: :unprocessable_entity
      end
    end

    def show; end

    def destroy
      @condition.destroy
      redirect_to conditions_path, notice: "記録が削除されました。"
    end

    private

    def set_conditions
      @condition = current_user.conditions.find(params[:id]) || []
    rescue ActiveRecord::RecordNotFound
      redirect_to conditions_path, alert: "指定された記録が見つかりませんでした。"
    end

    def condition_params
      params.require(:condition).permit(:fatigue_level, :body_temperature, :sleep_hours, :mental_state, :recorded_on)
    end

    def authorize_approved
      unless current_user.team_invitations.where(status: :approved).exists?
        redirect_to root_path, alert: "権限がありません。"
      end
    end
end
