class PhoneNumber < ActiveRecord::Base
  KINDS = [:private, :direct, :business, :fax, :mobile, :other]
  KINDS_FOR_MEMBER = KINDS - [:business]
  KINDS_FOR_FACILITY = KINDS - [:private, :direct]

  belongs_to :phone_owner, :polymorphic => true

  validates :kind, :number, :presence => true

  def localized_kind
    I18n.translate(kind)
  end
end
