module AddressesHelper
  def options_for_kinds(kinds)
    kinds.map { |k| [t(".#{k}"), k] }
  end
end
