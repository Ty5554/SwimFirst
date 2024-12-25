class TrainingMenusController < ApplicationController
    before_action :set_training_menus, only: %i[show edit update destroy]
    before_action :set_team
    before_action :authenticate_user!
    before_action :authorize_approved, only: %i[index new create edit update show edit update destroy]
    before_action :authorize_coach, only: [ :new, :create ]

    def index
      @training_menus = TrainingMenu.joins(user: :teams)
      .where(teams: { id: current_user.teams.ids })
      .distinct
      .includes(:training_sets).page(params[:page]).per(6)
      
      @training_sets = TrainingSet.joins(:training_menu)
      .where(training_menu: { id: @training_menus.map(&:id) })
    end

    def new
      @training_menu = current_user.training_menus.build
      @training_menu.training_sets.build
    end

    def create
      @training_menu = current_user.training_menus.new(training_menu_params)

      if @training_menu.save
        redirect_to training_menus_path, notice: "トレーニングメニューが作成されました。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @training_menu = current_user.training_menus.find(params[:id])
    end

    def update
      if @training_menu.update(training_menu_params)
        redirect_to training_menus_path, notice: "トレーニングメニューが更新されました。"
      else
        flash.now[:alert] = "トレーニングメニューの更新に失敗しました"
        render :edit, status: :unprocessable_entity
      end
    end

    def show; end

    def destroy
      @training_menu.destroy
      redirect_to training_menus_path, notice: "トレーニングメニューが削除されました。"
    end

    private

    def set_training_menus
      @training_menu = TrainingMenu.joins(user: :teams)
                                   .where(teams: { id: current_user.teams.ids })
                                   .find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to training_menus_path, alert: "指定されたトレーニングメニューが見つかりませんでした。"
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

    def authorize_approved
      unless current_user.team_invitations.where(status: :approved).exists?
        redirect_to root_path, alert: "権限がありません。メンバー管理ページにてステータスを更新してください。"
      end
    end

    def authorize_coach
      unless current_user.role&.coach?
        redirect_to root_path, alert: "権限がありません。"
      end
    end
end
