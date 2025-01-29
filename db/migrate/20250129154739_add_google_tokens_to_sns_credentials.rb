class AddGoogleTokensToSnsCredentials < ActiveRecord::Migration[7.2]
  def change
    add_column :sns_credentials, :google_access_token, :text
    add_column :sns_credentials, :google_refresh_token, :text
  end
end
