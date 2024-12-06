class TrainingSetsController < ApplicationController
  before_action :set_training_set, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :authorize_athlete!, only: %i[edit update]

  def create
    @training_set = current_user.training_sets.build(training_sets_params)
  end

  def edit
    # 編集画面を表示 (athleteユーザーのみアクセス可能)
  end

  def update
    if @training_set.update(training_set_params)
      redirect_to training_menu_path(@training_set.training_menu), notice: "心拍数が更新されました。"
    else
      flash.now[:alert] = "心拍数の更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # トレーニングセットを取得
  def set_training_set
    @training_set = TrainingSet.find(params[:id])
  end

  # 許可パラメータ (athlete用)
  def training_set_params
    params.require(:training_set).permit(:heart_rate)
  end

  # 認可チェック (athleteユーザーのみ許可)
  def authorize_athlete!
    unless current_user.role == "athlete"
      redirect_to root_path, alert: "権限がありません。"
    end
  end
end
