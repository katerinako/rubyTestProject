module MembersHelper
  def options_for_sex
    Member::SEXES.map { |s| [t(s, :scope => :sex), s] }
  end
  
  def options_for_filter
    [["All", "all"],
     ["SGDV", "SGDV"],
     ["Dermarena", "Dermarena"],
     ["Hidden in Addressbook", "Hidden"],
     ["Passed Away", "Passed Away"],
     ["Company", "Company"],
     ["Ordinary Members", "Ordinary Members"]]
  end
end
