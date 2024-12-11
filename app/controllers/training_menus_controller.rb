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
      .includes(:training_sets)
    end

    def new
      @training_menu = current_user.training_menus.build
      @training_menu.training_sets.build
    end

    def create
      @training_menu = current_user.training_menus.new(training_menu_params)

      @training_menu.training_sets.each do |set|
        set.athlete_id ||= current_user.id if current_user.role.athlete?
      end
      
      if @training_menu.save
        redirect_to training_menus_path, notice: "記録が作成されました。"
      else
        Rails.logger.debug @training_menu.errors.full_messages
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @training_menu = TrainingMenu.joins(user: :teams)
      .where(teams: { id: current_user.teams.ids })
      .find(params[:id])
    end

    def update
      if current_user.role.coach?
        if @training_menu.update(training_menu_params)
          redirect_to training_menus_path, notice: "記録が更新されました。"
        else
          flash.now[:alert] = "記録の更新に失敗しました"
          render :edit, status: :unprocessable_entity
        end
      elsif current_user.role.athlete?
        # heart_rateのみ更新を許可
        if update_heart_rate
          redirect_to training_menus_path, notice: "心拍数が更新されました。"
        else
          flash.now[:alert] = "心拍数の更新に失敗しました。"
          render :edit, status: :unprocessable_entity
        end
      else
        redirect_to root_path, alert: "権限がありません。"
      end
    end

    def show; end

    def destroy
      @training_menu.destroy
      redirect_to training_menus_path, notice: "記録が削除されました。"
    end 

    private

    def set_training_menus
      @training_menu = TrainingMenu.joins(user: :teams)
                                   .where(teams: { id: current_user.teams.ids })
                                   .find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to training_menus_path, alert: "指定された記録が見つかりませんでした。"
    end

    def training_menu_params
      params.require(:training_menu).permit(
        :training_date,
        :description,
        training_sets_attributes: [ :id, :intensity, :set_number, :_destroy, :heart_rate, :athlete_id ]
      )
    end

    def heart_rate_set_params
      params.require(:training_menu).permit(training_sets_attributes: [:id, :heart_rate])
    end

    def update_heart_rate
      params[:training_menu][:training_sets_attributes].each do |_, set_params|
        set = TrainingSet.find(set_params[:id])
        if set.athlete_id == current_user.id
          set.update(heart_rate: set_params[:heart_rate])
        end
      end
    
      redirect_to training_menus_path, notice: "心拍数が更新されました。"
=begin
      heart_rate_updates = heart_rate_set_params[:training_sets_attributes].to_h.values
  
      ActiveRecord::Base.transaction do
        heart_rate_updates.each do |set_params|
          training_set = @training_menu.training_sets.find(set_params[:id])
          training_set.update!(heart_rate: set_params[:heart_rate])
        end
      end
      true
    rescue ActiveRecord::RecordInvalid
      false
=end
    end

    def set_team
      @team = current_user.teams.first if user_signed_in?
    end

    def authorize_approved
      unless current_user.team_invitations.where(status: :approved).exists?
        redirect_to root_path, alert: "権限がありません。"
      end
    end

    def authorize_coach
      unless current_user.role&.coach?
        redirect_to root_path, alert: "権限がありません。"
      end
    end
end
