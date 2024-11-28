class RegistrationsController < Devise::RegistrationsController
    def new
      build_resource({})
      resource.build_role unless resource.role.present?
      Rails.logger.debug "DEBUG: Role object in new: #{resource.role.inspect}"
      super
    end

  def create
    build_resource(sign_up_params)
    resource.build_role(role_params) unless resource.role.present?
    
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

  def role_params
    params.require(:user).require(:role_attributes).permit(:role)
  end
end