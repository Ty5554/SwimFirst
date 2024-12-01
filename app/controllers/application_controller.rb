class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_team

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, role_attributes: [:role], teams_attributes: [:team_name]])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, role_attributes: [:role], teams_attributes: [:team_name]])
  end

  def set_team
    @team = current_user.teams.first if user_signed_in?
  end
end
