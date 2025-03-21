class SelfRecordsController < ApplicationController
    before_action :set_self_records, only: %i[show edit update destroy]
    before_action :authenticate_user!
    before_action :authorize_approved, only: %i[index new create edit update show edit update destroy]

    def index
      @q = current_user.self_records.page(params[:page]).per(5).ransack(params[:q])
      @self_records = @q.result(distinct: true)
      @all_q = SelfRecord.joins(user: :teams)
                         .where(teams: { id: current_user.teams.ids })
                         .distinct
                         .page(params[:page]).per(5)
                         .ransack(params[:all_q])
      @all_records = @all_q.result(distinct: true)
      @athletes = current_user.teams.includes(:users).flat_map(&:users)
    end

    def new
      @self_record = current_user.self_records.new
    end

    def create
      @self_record = current_user.self_records.new(self_record_params)
      if @self_record.save
        redirect_to self_records_path, notice: "記録が作成されました。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @self_record = current_user.self_records.find(params[:id])
    end

    def update
      if @self_record.update(self_record_params)
        redirect_to self_records_path, notice: "記録が更新されました。"
      else
        flash.now[:alert] = "記録の更新に失敗しました"
        render :edit, status: :unprocessable_entity
      end
    end

    def show; end

    def destroy
      @self_record.destroy
      redirect_to self_records_path, notice: "記録が削除されました。"
    end

    private

    def set_self_records
      @self_record = current_user.self_records.find(params[:id]) || []
    rescue ActiveRecord::RecordNotFound
      redirect_to self_records_path, alert: "指定された記録が見つかりませんでした。"
    end

    def self_record_params
      params.require(:self_record).permit(:style, :distance, :record, :recorded_on)
    end

    def authorize_approved
      unless current_user.team_invitations.where(status: :approved).exists?
        redirect_to root_path, alert: "権限がありません。メンバー管理ページにてステータスを更新してください。"
      end
    end
end
