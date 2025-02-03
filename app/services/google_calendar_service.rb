require "google/apis/calendar_v3"
require "googleauth"

class GoogleCalendarService
  def initialize(user)
    @sns_credential = user.sns_credentials.find_by(provider: "google_oauth2")
    raise "Google OAuth not linked" unless @sns_credential

    @service = Google::Apis::CalendarV3::CalendarService.new
    refresh_token_if_expired
  end

  def create_event(training_menu)
    event = Google::Apis::CalendarV3::Event.new(
      summary: "トレーニングメニュー: #{training_menu.description}",
      start: { date_time: training_menu.training_date.to_time.iso8601, time_zone: "Asia/Tokyo" },
      end: { date_time: (training_menu.training_date.to_time + 1.hour).iso8601, time_zone: "Asia/Tokyo" }
    )

    @service.insert_event("primary", event)  # ← ここで引数エラーの可能性
  end

  private

  def refresh_token_if_expired
    @service.authorization = Signet::OAuth2::Client.new(
      client_id: Rails.application.credentials.dig(:google, :client_id),
      client_secret: Rails.application.credentials.dig(:google, :client_secret),
      token_credential_uri: "https://oauth2.googleapis.com/token",
      refresh_token: @sns_credential.google_refresh_token,
      access_token: @sns_credential.google_access_token
    )

    # 既存のトークンが存在し、有効期限が切れている場合に更新
    if @sns_credential.google_access_token.nil? || Time.now >= @sns_credential.updated_at + 3500.seconds
      new_token = @service.authorization.fetch_access_token!
      @sns_credential.update!(google_access_token: new_token["access_token"])
    end
  end
end
