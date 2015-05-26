module PhoneNumbersHelper
  def options_for_kind(kinds = PhoneNumber::KINDS)
    kinds.map { |k| [t(".#{k}"), k] }
  end
end
