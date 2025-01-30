class SnsCredential < ApplicationRecord
  belongs_to :user

  def update_google_tokens(auth)
    update!(
      google_access_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token.presence || google_refresh_token
    )
  end
end
