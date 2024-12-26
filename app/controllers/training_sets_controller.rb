class TrainingSetsController < ApplicationController
  def new
    @training_menu = TrainingMenu.find(params[:training_menu_id])
    @training_sets = @training_menu.training_sets.includes(:heart_rates)

    @training_sets.each do |training_set|
        training_set.heart_rates.build(user: current_user)
    end
  end

  def create
    @training_menu = TrainingMenu.find(params[:training_menu_id])

    begin
      ActiveRecord::Base.transaction do
        params[:heart_rates].each do |training_set_id, heart_rate|
          HeartRate.create!(
            training_set_id: training_set_id,
            user: current_user,
            training_heart_rate: heart_rate
          )
        end
      end
      redirect_to training_menus_path, notice: "心拍数が保存されました。"
    rescue ActiveRecord::RecordInvalid
      flash.now[:alert] = "心拍数の保存に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @training_menu = TrainingMenu.find(params[:training_menu_id]) # トレーニングメニューを取得
    @training_sets = @training_menu.training_sets.includes(:heart_rates) # セットと関連する心拍数を取得

    # 現在のユーザーに関連する心拍数データをロード
    @training_sets.each do |training_set|
      heart_rate = training_set.heart_rates.find_by(user: current_user)
      training_set.heart_rates.build(user: current_user) unless heart_rate # 存在しない場合は新規作成用のオブジェクトを準備
    end
  end

  def update_all
    @training_menu = TrainingMenu.find(params[:training_menu_id])

    begin
      ActiveRecord::Base.transaction do
        params[:heart_rates].each do |training_set_id, heart_rate_value|
          training_set = TrainingSet.find(training_set_id)
          heart_rate = training_set.heart_rates.find_by(user: current_user)
          if heart_rate
            heart_rate.update!(training_heart_rate: heart_rate_value)
          else
            HeartRate.create!(
              training_set_id: training_set_id,
              user: current_user,
              training_heart_rate: heart_rate_value
            )
          end
        end
      end
      redirect_to training_menus_path, notice: "心拍数が更新されました。"
    rescue ActiveRecord::RecordInvalid
      flash.now[:alert] = "心拍数の更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end


  private

  def training_set_params
    params.require(:training_set).permit(
      :set_number,
      :intensity,
      heart_rates_attributes: [ :id, :training_heart_rate, :_destroy ]
    )
  end
end
