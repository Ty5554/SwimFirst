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

      if params[:training_menu_id].present?
        @training_set = TrainingSet.joins(:training_menu)
                                   .where(training_menu: { id: params[:training_menu_id] })
                                   .first # 最初の関連セットを取得
      else
        # デフォルトで関連する最初のメニューのセットを取得
        @training_set = TrainingSet.joins(:training_menu)
                                   .where(training_menu: { id: @training_menus.map(&:id) })
                                   .first
      end
    end

    def new
      @training_menu = current_user.training_menus.build
      @training_menu.training_sets.build
    end

    def create
      @training_menu = current_user.training_menus.new(training_menu_params)

      if @training_menu.save
=begin
        begin
          calendar_service = GoogleCalendarService.new(current_user)
          calendar_service.create_event(@training_menu)
          flash[:notice] = "トレーニングメニューが作成され、Googleカレンダーに追加されました。"
        rescue => e
          Rails.logger.error "Googleカレンダーの登録に失敗: #{e.message}"
          flash[:alert] = "トレーニングメニューは作成されましたが、Googleカレンダーへの登録に失敗しました。"
        end
=end
        redirect_to training_menus_path
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
