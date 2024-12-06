class TrainingMenusController < ApplicationController
    before_action :set_training_menus, only: %i[show edit update destroy]
    before_action :set_team
    before_action :authenticate_user!

    def index
      @training_menus = current_user.training_menus.includes(:training_sets)
    end

    def new
      @training_menu = current_user.training_menus.build
      @training_menu.training_sets.build
    end

    def create
      @training_menu = current_user.training_menus.new(training_menu_params)
      Rails.logger.debug params.inspect
      if @training_menu.save
        redirect_to training_menus_path, notice: "記録が作成されました。"
      else
        Rails.logger.debug @training_menu.errors.full_messages
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @training_menu = current_user.training_menus.find(params[:id])
    end

    def update
      if @training_menu.update(training_menu_params)
        redirect_to training_menus_path, notice: "記録が更新されました。"
      else
        flash.now[:alert] = "記録の更新に失敗しました"
        render :edit, status: :unprocessable_entity
      end
    end

    def show; end

    def destroy
      @training_menu.destroy
      redirect_to training_menus_path, notice: "記録が削除されました。"
    end

    private

    def set_training_menus
      @training_menu = current_user.training_menus.find(params[:id]) || []
    rescue ActiveRecord::RecordNotFound
      redirect_to training_menus_path, alert: "指定された記録が見つかりませんでした。"
    end

    def training_menu_params
      params.require(:training_menu).permit(
        :training_date, 
        :description, 
        training_sets_attributes: [ :id, :intensity, :set_number, :_destroy ]
      )
    end

    def set_team
      @team = current_user.teams.first if user_signed_in?
    end
end
