#require_relative 'application_mailer'

class ExamNotifications < ApplicationMailer
  default :from => "DERMA.CH (SGDV /SSDV) <no-reply@derma.ch>"

  # sent to application that his applicaiton has been submitted
  def application_confirmed(exam_candidate)
    @exam_candidate = exam_candidate
    
    using_locale @exam_candidate.language do
      mail :to => @exam_candidate.email_address_with_name
    end
  end

  def ask_for_confirmation(exam_candidate, recipient, ccs=[])
    @exam_candidate = exam_candidate
    @recipient = recipient
    @recipient_name = if recipient.respond_to?(:name)
                        recipient.name
                      else
                        recipient
                      end

    language = if recipient.respond_to?(:language)
                 recipient.language
               else
                 :de
               end
    to_address = if recipient.respond_to?(:email_address_with_name)
                   recipient.email_address_with_name
                 else
                   recipient
                 end
    

    using_locale language do
      mail :to => to_address, 
           :cc => ccs.map(&:email_address_with_name)
    end
  end
  
  def ask_for_confirmation_sgdv(exam_candidate, recipient, ccs=[])
    @exam_candidate = exam_candidate
    @recipient = recipient
    @recipient_name = if recipient.respond_to?(:name)
                        recipient.name
                      else
                        recipient
                      end

    language = if recipient.respond_to?(:language)
                 recipient.language
               else
                 :de
               end
    to_address = if recipient.respond_to?(:email_address_with_name)
                   recipient.email_address_with_name
                 else
                   recipient
                 end
    

    using_locale language do
      mail :to => to_address, 
           :cc => ccs.map(&:email_address_with_name)
    end
  end
  

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.exam_notifications.application_approved.subject
  #
  def application_approved(exam_candidate)
    @exam_candidate = exam_candidate
    
    using_locale @exam_candidate.language do
      mail :to => @exam_candidate.email_address_with_name
    end
  end

  private

  def exams_email
    Rails.application.config.exams_email
  end
end
