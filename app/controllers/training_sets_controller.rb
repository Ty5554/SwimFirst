class TrainingSetsController < ApplicationController
  before_action :set_training_set, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :authorize_athlete!, only: %i[edit_heart_rate update_heart_rate]

  before_validation :set_athlete

  def create
    @training_set = TrainingSet.new(heart_rate_set_params)
    @training_set.athlete_id = current_user.id
  
    if @training_set.save
      redirect_to training_menu_path(@training_set.training_menu_id), notice: "トレーニングセットが作成されました。"
    else
      flash.now[:alert] = "トレーニングセットの作成に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def update_heart_rate_sets
    params[:training_menu][:training_sets_attributes].each do |_, set_params|
      training_set = @training_menu.training_sets.find(set_params[:id])
      if training_set.athlete_id == current_user.id
        training_set.update(heart_rate: set_params[:heart_rate])
      end
    end
    true
  end

  private

  # トレーニングセットを取得
  def set_training_set
    @training_set = TrainingSet.find(params[:id])
  end

  def set_athlete
    self.athlete_id ||= Current.user&.id # 現在のユーザーを自動的にathlete_idに設定
  end

  # 許可パラメータ (athlete用)
  def heart_rate_set_params
    params.require(:training_set).permit(:heart_rate, :training_menu_id, :set_number, :intensity)
  end

  # 認可チェック (athleteユーザーのみ許可)
  def authorize_athlete!
    unless current_user.role == "athlete"
      redirect_to root_path, alert: "権限がありません。"
    end
  end
end
