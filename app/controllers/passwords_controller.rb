class PasswordsController < Devise::PasswordsController 
  before_action :set_mailer_host, only: [:create]
  
  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  # def update
  #   self.resource = resource_class.reset_password_by_token(resource_params)
  #   yield resource if block_given?

  #   if resource.errors.empty?
  #     resource.unlock_access! if unlockable?(resource)
  #     if Devise.sign_in_after_reset_password
  #       set_flash_message!(:notice, "Your password has been updated!")
  #     else
  #       set_flash_message!(:notice, :updated_not_active)
  #     end
  #     respond_with resource, location: after_resetting_password_path_for(resource)
  #   else
  #     set_minimum_password_length
  #     respond_with resource
  #   end
  # end
end