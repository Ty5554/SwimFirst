class SelfRecordsController < ApplicationController
    before_action :set_self_records, only: %i[show edit update destroy]
    before_action :authenticate_user!

    def index
      @self_records = current_user.self_records
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
end