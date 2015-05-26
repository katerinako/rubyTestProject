module FacilitiesHelper
  def options_for_facility_kinds
    Facility::KINDS.map {|k| [t(k), k] }
  end

  def kind_filters
    [["All", "ALL"]] + options_for_facility_kinds
  end

  def education_filters
    [["All", "ALL"], ["Empty", "EMPTY"]] + Facility::EDUCATION_TYPES.map {|t| [t, t] }
  end
end
