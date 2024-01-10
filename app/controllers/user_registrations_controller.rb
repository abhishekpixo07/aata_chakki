# frozen_string_literal: true

class UserRegistrationsController < Devise::RegistrationsController
  before_action :check_permissions, only: [:edit, :update]
  skip_before_action :require_no_authentication

  def create
    phone_number = spree_user_params[:phone_number]
    existing_user = Spree::User.find_by(phone_number: phone_number)
  
    if existing_user
      send_otp_and_redirect(existing_user)
    else
      create_and_send_otp
    end
  end
  
   # Action for entering OTP
  def enter_otp
    @user = Spree::User.find(params[:id])
  end

  # Action for confirming OTP
  def confirm_otp
    p "-00000000-"
    p params[:otp]
    otp_string = params[:otp].join('') if params[:otp].is_a?(Array)
    user = Spree::User.find(params[:id])
    if user && user.otp == otp_string
      user.update(user_active: true,otp: nil)
      sign_in(:spree_user, user)
      session[:spree_user_signup] = true
      redirect_to edit_user_path(user.id), notice: 'Account verified successfully.' if (!user.first_name.present? && !user.last_name.present? && !user.email.present? )
      redirect_to root_path, notice: 'Account Login successfully.'  if (user.first_name.present? && user.last_name.present? && user.email.present? )
    else
      redirect_to enter_otp_path(id: user.id), alert: 'Invalid OTP. Please try again.'
    end
  end

  protected

  def translation_scope
    'devise.user_registrations'
  end

  def check_permissions
    authorize!(:create, resource)
  end

  private

  def spree_user_params
    params.require(:spree_user).permit(Spree::PermittedAttributes.user_attributes | [:phone_country_code,:phone_number])
  end

  def send_otp resource
    UserMailer.send_otp(resource).deliver_now
  end

  def create_and_send_otp
    build_resource(spree_user_params)
    resource.otp = rand(1000..9999).to_s # Adjust the length of OTP as needed
  
    if resource.save
      send_otp_via_twilio(resource) if resource.phone_number.present?
      flash[:alert] = "OTP sent successfully on phone. Please enter it below."
      redirect_to enter_otp_path(id: resource.id)
    else
      clean_up_passwords(resource)
      respond_with(resource) { |format| format.html { render :new } }
    end
  end
  
  def send_otp_and_redirect(user)
    user.update(otp: rand(1000..9999).to_s)
    send_otp_via_twilio(user) if user.phone_number.present?
    flash[:notice] = "OTP sent successfully on phone. Please enter it below."
    redirect_to enter_otp_path(id: user.id)
  end

  def send_otp_via_twilio(resource)
    formatted_phone_number = "+#{resource.phone_country_code}#{resource.phone_number}"
    $twilio_client.messages.create(
      from: '+12137845665',
      to: formatted_phone_number,
      body: "Your OTP is #{resource.otp}."
    )
  end
end
