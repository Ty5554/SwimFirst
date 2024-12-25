class HeartRatesController < ApplicationController
  before_action :set_training_set
  before_action :set_heart_rate, only: [:edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @training_menus = TrainingMenu.joins(user: :teams)
    .where(teams: { id: current_user.teams.ids })
    .distinct
    .includes(:training_sets).page(params[:page]).per(6)

    @heart_rates = @training_set.heart_rates.includes(:user)
  end

  def new
    @heart_rate = @training_set.heart_rates.build
  end

  def create
    @heart_rate = @training_set.heart_rates.new(heart_rate_params)
    @heart_rate.user = current_user

    if @heart_rate.save
      redirect_to training_menu_path(@training_set.training_menu), notice: '心拍数が追加されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @heart_rate.update(heart_rate_params)
      redirect_to training_menu_path(@training_set.training_menu), notice: '心拍数が更新されました。'
    else
      flash.now[:alert] = '心拍数の更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @heart_rate.destroy
    redirect_to training_menu_path(@training_set.training_menu), notice: '心拍数が削除されました。'
  end

  private

  def set_training_set
    @training_set = TrainingSet.joins(:training_menu)
                               .where(training_menus: { id: params[:training_menu_id] })
                               .find(params[:training_set_id])
    if @training_set.nil?
      redirect_to root_path, alert: '指定されたトレーニングセットが見つかりませんでした。'
    end
  end

  def set_heart_rate
    @heart_rate = @training_set.heart_rates.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: '指定された心拍数データが見つかりませんでした。'
  end

  def heart_rate_params
    params.require(:heart_rate).permit(:training_heart_rate)
  end
end
