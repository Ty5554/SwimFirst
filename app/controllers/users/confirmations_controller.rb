class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.find_by_confirmation_token(params[:confirmation_token])

    if resource.nil? || resource.confirmed?
      # トークンが不正な場合、アカウント登録(パスワード登録)が済んでいる場合
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      render :show
    elsif resource.is_confirmation_period_expired?
      # アカウント登録メールの期限が切れた場合
      resource.errors.add(:email, :confirmation_period_expired,
        period: Devise::TimeInflector.time_ago_in_words(resource_class.confirm_within.ago))
      render :show
    else
      # activate
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      redirect_to new_user_session_path, notice: "メールアドレスを確認しました。"
    end
  end
end
