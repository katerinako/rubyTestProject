module MemberCandidateMailerHelper
  def self.included(base)
    base.send(:include, SalutationHelpers)
  end
end