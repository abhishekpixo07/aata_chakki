# frozen_string_literal: true

class UsersController < StoreController
  skip_before_action :set_current_order, only: [:show], raise: false
  prepend_before_action :authorize_actions, only: :new

  include Taxonomies

  def show
    load_object
    @orders = @user.orders.complete.order('completed_at desc')
  end

  def create
    @user = Spree::User.new(user_params)
    if @user.save

      if current_order
        session[:guest_token] = nil
      end

      redirect_back_or_default(root_url)
    else
      render :new
    end
  end

  def user_susbscription
    @subscription_plans = SolidusSubscriptions::SubscriptionPlan.all
  end

  def create_subscription
    load_object
     # Parse the JSON data from the request
     data = JSON.parse(request.body.read)
     # Extract necessary information
     razorpay_payment_id = data['razorpay_payment_id']
     amount = data['amount']
    p ":_----------------"
    p @user
     # Your logic to create the subscription based on payment success
     # Example: Creating a subscription for the current user
     subscription = SolidusSubscriptions::Subscription.create!(
       user_id: @user.id, # Replace with your user identification logic
       amount: amount,
       currency: "INR",
       payment_source_type: 'Razorpay',
       payment_source_id: razorpay_payment_id

     ) 
    if subscription.save
      alert('Subscription successful!');
      render json: { status: 'success', message: 'Subscription created successfully' }
    else
      render json: { status: 'error', message: 'Failed to create subscription' }, status: :unprocessable_entity
    end
  end

  def edit
    load_object
  end

  def update
    load_object
  
    # Check if the provided email already exists for another user
    existing_user = Spree::User.find_by(email: user_params[:email])
  
    if existing_user && existing_user.id != @user.id
      # Email already exists for another user
      flash.now[:alert] = "This email is already in use by another user. Please choose a different one."
      render :edit
    else
      # Email doesn't exist or belongs to the same user, proceed with the update
      if @user.update(user_params)
        spree_current_user.reload
        redirect_url = account_url
  
        if params[:user][:password].present?
          # this logic needed b/c devise wants to log us out after password changes
          if Spree::Auth::Config[:signout_after_password_change]
            redirect_url = login_url
          else
            bypass_sign_in(@user)
          end
        end
        redirect_to redirect_url, notice: I18n.t('spree.account_updated')
      else
        flash.now[:alert] = "An error occurred while updating your account."
        render :edit
      end
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, :current_password)
  end
  
  private

  def user_params
    params.require(:user).permit(Spree::PermittedAttributes.user_attributes | [:email,:first_name,:last_name])
  end

  def load_object
    @user ||= Spree::User.find_by(id: spree_current_user&.id)
    authorize! params[:action].to_sym, @user
  end

  def authorize_actions
    authorize! params[:action].to_sym, Spree::User.new
  end

  def accurate_title
    I18n.t('spree.my_account')
  end
end
