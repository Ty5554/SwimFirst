require "csv"

class ConditionsController < ApplicationController
    before_action :set_conditions, only: %i[show edit update destroy]
    before_action :authenticate_user!
    before_action :authorize_approved, only: %i[index export new create edit update show edit update destroy]

    def index
      @q = current_user.conditions.page(params[:page]).per(5).ransack(params[:q])
      @conditions = @q.result(distinct: true)
      @all_q = Condition.joins(user: :teams)
                        .where(teams: { id: current_user.teams.ids })
                        .distinct
                        .page(params[:page]).per(5)
                        .ransack(params[:all_q])
      @all_conditions = @all_q.result(distinct: true)
      @athletes = current_user.teams.includes(:users).flat_map(&:users)
    end

    def export
      condition_data = if current_user.role.athlete?
        current_user.conditions
      elsif current_user.role.coach?
        Condition.joins(user: :teams)
                 .where(teams: { id: current_user.teams.ids })
                 .distinct
      else
        [] # 万が一ロールが想定外の場合のデフォルト
      end

      respond_to do |format|
        format.csv do
          headers = %w[CONDITION_ID FATIGUE_LEVEL MENTAL_FATIGUE_LEVEL BODY_TEMPERATURE SLEEP_DURATION RECORDED_DATE NAME]
          csv_data = CSV.generate(headers: true) do |csv|
            csv << headers
            condition_data.each do |condition|
              csv << [
                condition.id,
                condition.fatigue_level,
                condition.mental_state,
                condition.body_temperature,
                condition.sleep_hours,
                condition.recorded_on,
                condition.user.full_name
              ]
            end
          end
          send_data csv_data, filename: "conditions_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv", type: :csv
        end
      end
    end

    def new
      @condition = current_user.conditions.new
    end

    def create
      @condition = current_user.conditions.new(condition_params)
      if @condition.save
        redirect_to conditions_path, notice: "コンディションデータが作成されました。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @condition= current_user.conditions.find(params[:id])
    end

    def update
      if @condition.update(condition_params)
        redirect_to conditions_path, notice: "コンディションデータが更新されました。"
      else
        flash.now[:alert] = "コンディションデータの更新に失敗しました"
        render :edit, status: :unprocessable_entity
      end
    end

    def show; end

    def destroy
      @condition.destroy
      redirect_to conditions_path, notice: "コンディションデータが削除されました。"
    end

    private

    def set_conditions
      @condition = current_user.conditions.find(params[:id]) || []
    rescue ActiveRecord::RecordNotFound
      redirect_to conditions_path, alert: "指定されたコンディションデータが見つかりませんでした。"
    end

    def condition_params
      params.require(:condition).permit(:fatigue_level, :body_temperature, :sleep_hours, :mental_state, :recorded_on)
    end

    def authorize_approved
      unless current_user.team_invitations.where(status: :approved).exists?
        redirect_to root_path, alert: "権限がありません。メンバー管理ページにてステータスを更新してください。"
      end
    end
end
