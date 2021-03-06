module Users
  module UpdatingService
    include BaseService

    def call(user, params, flash = {})
      user.transaction do
        user.assign_attributes(params)

        if user.valid?
          EmailConfirmationService.send_email(user, flash) if user.email_changed? && user.email?
        end

        user.save || rollback!
      end
    end
  end
end
