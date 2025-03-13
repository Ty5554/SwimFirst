# app/services/recaptcha_service.rb
require "google/cloud/recaptcha_enterprise"

class RecaptchaService
  RECAPTCHA_PROJECT_ID = ENV["GOOGLE_CLOUD_PROJECT_ID"]
  RECAPTCHA_SITE_KEY = ENV["RECAPTCHA_SITE_KEY"]

  def self.verify(token, action)
    client = ::Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service

    request = {
      parent: "projects/#{RECAPTCHA_PROJECT_ID}",
      assessment: {
        event: {
          site_key: RECAPTCHA_SITE_KEY,
          token: token
        }
      }
    }

    response = client.create_assessment(request)

    if !response.token_properties.valid
      Rails.logger.warn "reCAPTCHA トークンが無効: #{response.token_properties.invalid_reason}"
      false
    elsif response.token_properties.action != action
      Rails.logger.warn "reCAPTCHA アクションが一致しません: #{response.token_properties.action} != #{action}"
      false
    else
      Rails.logger.info "reCAPTCHA スコア: #{response.risk_analysis.score}"
      response.risk_analysis.score.to_f > 0.5
    end
  rescue => e
    Rails.logger.error "reCAPTCHA API 呼び出しエラー: #{e.message}"
    false
  end
end
