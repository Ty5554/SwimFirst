class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_team
  before_action :set_modal_flag, if: :user_signed_in?

  def hide_modal
    if user_signed_in? && !current_user.modal_shown
      current_user.update(modal_shown: true)
    end
    head :ok
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, role_attributes: [ :role ], teams_attributes: [ :team_name ] ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, role_attributes: [ :role ], teams_attributes: [ :team_name ] ])
  end

  def set_team
    @team = current_user.teams.first if user_signed_in?
  end

  def set_modal_flag
    @show_modal = false
    @modal_type = nil

  #`params[:show_modal]` があれば、強制的にモーダルを開く
    if params[:show_modal].present? && !current_user.modal_shown
      @show_modal = true
      @modal_type = params[:show_modal]
      # モーダルを一度開いたら `modal_shown` を true に更新する
      current_user.update(modal_shown: true)
      return
    end

    return unless user_signed_in? && !current_user.modal_shown

    case params[:show_modal]
    when "invite"
      @show_modal = true
      @modal_type = params[:show_modal]
    end
  end
end
