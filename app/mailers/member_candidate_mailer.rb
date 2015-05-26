class MemberCandidateMailer < ApplicationMailer
  default :from => "DERMA.CH (SGDV /SSDV) <no-reply@derma.ch>"

  def confirmation_email(member_candidate)
    @member_candidate = member_candidate

    using_locale(@member_candidate.language || I18n.default_locale) do
      mail(:to => member_candidate.email_address,
           :subject => "Your SGDV Membership Application Has been Received")
    end
  end

  def registration_email(member_candidate)
    @member_candidate = member_candidate

    destination = sbm_email

    using_locale(I18n.default_locale) do
      mail(:to => destination,
           :subject => "derma.ch received a membership application by #{member_candidate.name}")
    end
  end

  def accepted_email(member_candidate, member)
    @member_candidate = member_candidate
    @member = member

    using_locale(@member_candidate.language || I18n.default_locale) do
      mail(:to => member_candidate.email_address,
           :reply_to => sbm_email,
           :subject => "Your SGDV Membership has been approved!")
    end
  end

  def rejected_email(member_candidate, member)
    @member_candidate = member_candidate
    @member = member

    using_locale(@member_candidate.language || I18n.default_locale) do
      mail(:to => member_candidate.email_address,
           :reply_to => sbm_email,
           :subject => "Your SGDV application has not been approved")
    end
  end

  private

  def sbm_email
    Rails.application.config.sgdv_registration_desk_email
  end
end
