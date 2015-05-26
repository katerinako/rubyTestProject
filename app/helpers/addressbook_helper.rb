module AddressbookHelper
  def with_hints?
    not @search.with_equipment_term.blank?
  end

  def phone_type(phone)
    case phone.kind.to_sym
    when :fax
      "F"
    when :direct
      "D"
    else
      "T"
    end
  end
end
