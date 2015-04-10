class SslController < ApplicationController
  def index
  end

  def about
  end

  def admin
  end

  def search
  end

  def users
  	@users = []
  	# Show admins all users so they can promote users
  	if current_user.try(:admin?)
  		@users = User.all.order(admin: :desc, sign_in_count: :desc, email: :asc)
  	elsif user_signed_in?
  		# Only show the admins to other users, so they can request a promotion
  		@users = User.where(admin: true).order(sign_in_count: :desc, email: :asc)
  	end
  end

  def promote_user
  	if current_user.email == 'jake.schmitz101@gmail.com' or (current_user.try(:admin?) and params[:promote_id])
  		user_to_promote = User.find(params[:promote_id])
  		puts user_to_promote
  		if 
  			user_to_promote.update_attributes(admin: true)
  			redirect_to root_path, notice: 'User was promoted to admin status.'
  		else
  			redirect_to root_path, alert: 'User was already an admin!'
  		end
  	else
  		redirect_to root_path, alert: 'You do not have permission to promote that user'
  	end
  end
end
