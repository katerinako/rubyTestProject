class Address < ActiveRecord::Base
  extend DistinctFields

  KINDS = [:private, :business, :other]
  KINDS_FOR_MEMBER = [:private]
  KINDS_FOR_FACILITY = KINDS - [:private]

  belongs_to :address_owner, :polymorphic => true

  validates :kind, :street1, :postal_code, :city, :presence => true

  def localized_kind
    I18n.translate(kind)
  end
end
