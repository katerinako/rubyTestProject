class DesignationType < ActiveRecord::Base
  GROUPINGS = [:designation, :function, :praxis_function, :membership_nomination]
   
  default_scope order(:name)
  
  scope :designation_types,       where(:grouping => :designation)
  scope :functions,               where(:grouping => :function)
  scope :praxis_functions,        where(:grouping => :praxis_function)
  scope :membership_nominations,  where(:grouping => :membership_nomination)
  
  def self.all_functions
    functions + praxis_functions
  end
  
end
