class RegistrationsController < Devise::RegistrationsController

  def new
    build_resource({})
    resource.build_role unless resource.role.present?
    resource.teams.build if resource.teams.empty?
    super
  end

  def create
    build_resource(sign_up_params)
    resource.build_role(role_params) unless resource.role.present?
    resource.teams.build(teams_params) if resource.teams.empty?
    
    if resource.save
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :first_name, :last_name,
      role_attributes: [:role],
      teams_attributes: [:id]
    )
  end

  def role_params
    params.require(:user).require(:role_attributes).permit(:role)
  end

  def teams_params
    params.require(:user).require(:teams_attributes).permit(:team_name)
  end
end
