class DiariesController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = current_user.diaries.order(created_at: :desc).page(params[:page]).per(5).ransack(params[:q])
    @diaries = @q.result(distinct: true)
  end

  def new
    @diary = Diary.new
  end

  def create
    @diary = current_user.diaries.build(diary_params)

    if @diary.save
    feedback = AiService.get_feedback(@diary.content) # 直接 API を呼び出し
    @diary.update(feedback: feedback)
    redirect_to diaries_path, notice: "日誌を保存しました"
    else
    render :new, status: :unprocessable_entity
    end
  end

  def edit
    @diary= current_user.diaries.find(params[:id])
  end

  def update
    @diary = Diary.find_by(id: params[:id])
    if @diary.update(diary_params)
      redirect_to diaries_path, notice: "日誌が更新されました。"
    else
      flash.now[:alert] = "日誌の更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def show; end

  def destroy
    @diary = Diary.find_by(id: params[:id])
    if @diary
      @diary.destroy
      redirect_to diaries_path, notice: "投稿を削除しました。"
    else
      redirect_to diaries_path, alert: "対象の投稿が見つかりませんでした。"
    end
  end

  private

  def diary_params
    params.require(:diary).permit(:content, :recorded_on, :feedback)
  end
end
