=begin
require "google/apis/calendar_v3"
require "googleauth"

class GoogleCalendarService
  def initialize(user)
    @user = user
    @service = Google::Apis::CalendarV3::CalendarService.new
    refresh_token_if_expired
  end

  def create_event(training_menu)
    event = Google::Apis::CalendarV3::Event.new(
      summary: "トレーニングメニュー: #{training_menu.description}",
      start: { date_time: training_menu.training_date.to_time.iso8601 },
      end: { date_time: (training_menu.training_date.to_time + 1.hour).iso8601 }
    )

    @service.insert_event("primary", event)
  end

  private

  def refresh_token_if_expired
    @service.authorization = Signet::OAuth2::Client.new(
      client_id: Rails.application.credentials.dig(:google, :client_id),
      client_secret: Rails.application.credentials.dig(:google, :client_secret),
      token_credential_uri: "https://oauth2.googleapis.com/token",
      refresh_token: @user.google_refresh_token
    )

    if @service.authorization.expired?
      @service.authorization.fetch_access_token!
      @user.update!(google_access_token: @service.authorization.access_token)
    else
      @service.authorization.access_token = @user.google_access_token
    end
  end
end
=end