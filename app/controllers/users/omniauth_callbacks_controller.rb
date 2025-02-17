class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    callback_for(:google)
  end

  def callback_for(provider)
    @omniauth = request.env["omniauth.auth"]
    info = User.find_oauth(@omniauth)
    @user = info[:user]
    if @user.persisted?    # persisted?は保存が完了しているかを評価するメソッド
      # Google の OAuth 認証情報を SnsCredential に保存
      save_google_tokens(@user, @omniauth) if provider == :google

      if @user.sns_credentials.exists?(provider: "google_oauth2")
        @user.update(confirmed_at: Time.current) unless @user.confirmed?
      end

      if @user.role.nil? || @user.teams.empty?
        # 未設定の場合は登録完了ページへリダイレクト
        sign_in @user
        redirect_to complete_registration_path
      else
        sign_in_and_redirect @user, event: :authentication
        # is_navigational_formatはフラッシュメッセージを発行する必要があるかどうかを確認する
        # capitalizeは文字列の先頭を大文字に、それ以外は小文字に変更して返すメソッド
        set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
      end
    else
      @sns = info[:sns]
      render template: "devise/registrations/new"
    end
  end

  def failure
    redirect_to root_path and return
  end

  private

  def save_google_tokens(user, auth)
    sns_credential = SnsCredential.find_or_create_by(provider: auth.provider, uid: auth.uid, user: user)
    sns_credential.update!(
      google_access_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token.presence || sns_credential.google_refresh_token
    )
  end
end
