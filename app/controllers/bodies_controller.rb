class BodiesController < ApplicationController
    before_action :set_bodies, only: %i[show edit update destroy]
    before_action :authenticate_user!
    before_action :authorize_approved, only: %i[index new create edit update show edit update destroy]

    def index
      @q = current_user.bodies.page(params[:page]).per(5).ransack(params[:q])
      @bodies = @q.result(distinct: true)
      @all_q = ::Body.joins(user: :teams)
                        .where(teams: { id: current_user.teams.ids })
                        .distinct
                        .page(params[:page]).per(5)
                        .ransack(params[:all_q])
      @all_bodies = @all_q.result(distinct: true)
      @athletes = current_user.teams.includes(:users).flat_map(&:users)
    end

    def export
      body_data = if current_user.role.athlete?
        current_user.bodies
      elsif current_user.role.coach?
        ::Body.joins(user: :teams)
                 .where(teams: { id: current_user.teams.ids })
                 .distinct
      else
        [] # 万が一ロールが想定外の場合のデフォルト
      end

      respond_to do |format|
        format.csv do
          headers = %w[BODY_ID HEIGHT WEIGHT BODY_FAT RECORDED_DATE NAME]
          csv_data = CSV.generate(headers: true) do |csv|
            csv << headers
            body_data.each do |body|
              csv << [
                body.id,
                body.height,
                body.weight,
                body.body_fat,
                body.recorded_on,
                body.user.full_name
              ]
            end
          end
          send_data csv_data, filename: "bodiess_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv", type: :csv
        end
      end
    end

    def new
      @body = current_user.bodies.new
    end

    def create
      @body = current_user.bodies.new(body_params)
      if @body.save
        redirect_to bodies_path, notice: "フィジカルデータが作成されました。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @body= current_user.bodies.find(params[:id])
    end

    def update
      if @body.update(body_params)
        redirect_to bodies_path, notice: "フィジカルデータが更新されました。"
      else
        flash.now[:alert] = "フィジカルデータの更新に失敗しました"
        render :edit, status: :unprocessable_entity
      end
    end

    def show; end

    def destroy
      @body.destroy
      redirect_to bodies_path, notice: "フィジカルデータが削除されました。"
    end

    private

    def set_bodies
      @body = current_user.bodies.find(params[:id]) || []
    rescue ActiveRecord::RecordNotFound
      redirect_to bodies_path, alert: "指定されたフィジカルデータが見つかりませんでした。"
    end

    def body_params
      params.require(:body).permit(:height, :weight, :body_fat, :recorded_on)
    end

    def authorize_approved
      unless current_user.team_invitations.where(status: :approved).exists?
        redirect_to root_path, alert: "権限がありません。メンバー管理ページにてステータスを更新してください。"
      end
    end
end
