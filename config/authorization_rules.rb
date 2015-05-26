authorization do
  role :guest do
    # exam application form
    has_permission_on :exam_candidates, :to => :apply
    has_permission_on :member_candidates, :to => :apply
  end

  role :"sgdv-member" do
    includes :guest

    has_permission_on [:members, :organizational_units, :designations], :to => :see
    has_permission_on :members, :to => :my_profile

    has_permission_on :members, :to => :change_password do
      if_attribute :id => is { user.id }
    end

    has_permission_on [:addressbooks], :to => [:see,
                                               :autocomplete_personal,
                                               :autocomplete_function,
                                               :autocomplete_equipment,
                                               :autocomplete_business,
                                               :autocomplete_specialization,
                                               :autocomplete_postal_canton]

    # 2012-06-16: SGDV asked that members are not able to change their data
    has_permission_on :members, :to => [:see_date_of_birth] do
      if_attribute :id => is { user.id }
    end

    has_permission_on :memberships, :to => :see

    has_permission_on :facilities, :to => [:see]

    has_permission_on :posts, :to => [:see,]

    has_permission_on :invoices, :to => :see do
      if_attribute :membership => { :member => is { user } }
    end
  end

  role :SBM do
    includes :"sgdv-member"

    has_permission_on :attachments, :to => :download
    has_permission_on [:member_candidates], :to => [:manage, :determine, :set_status]
  end

  role :"sgdv-administrators" do
    includes :"sgdv-member"
    includes :SBM

    has_permission_on :addressbooks, :to => :export

    has_permission_on [:members,
                       :import,
                       :organizational_units,
                       :designations,
                       :posts,
                       :designation_types,
                       :equipment_types,
                       :facilities,
                       :membership_categories,
                       :memberships,
                       :invoices],
                      :to => :manage

    has_permission_on :members, :to => [:manage_group_membership, 
                                        :manage_designations, 
                                        :see_date_of_birth,
                                        :manage_inactivity]
    has_permission_on :organizational_units, :to => [:manage_designations, :see_specializations]
    has_permission_on :facilities, :to => :edit_category
  end

  role :"exam-applications" do
    includes :"sgdv-member"

    has_permission_on :attachments, :to => :download
    has_permission_on [:exams, :exam_candidates, :results], :to => :manage
    has_permission_on :exam_candidates, :to => :approve_by_sgdv
    has_permission_on :exam_candidates, :to => :approve_by_clinic_director do
      if_attribute :current_clinic => {:posts => {:member => is {user}, :function => "Klinikdirektor"}}
    end
  end

  role :superusers do
    has_omnipotence
  end
end

privileges do
  privilege :see do
    includes :index, :show
  end

  privilege :change_password do
    includes :edit_password, :update_password
  end

  privilege :change do
    includes :edit, :update, :change_password, :edit_with_facility
  end

  privilege :add_new do
    includes :new, :create
  end


  privilege :manage do
    includes :see
    includes :change
    includes :add_new
    includes :edit_groups
    includes :destroy
    includes :commit
  end
  
  privilege :manage_inactivity do
    includes :see_inactivity
    includes :edit_inactivity
  end

  privilege :manage_designations do
    includes :remove_designation
  end

  privilege :apply do
    includes :new, :create, :thank_you, :no_exams_available
  end

  privilege :manage_group_membership do
    includes :toggle_group_membership
  end

  privilege :approve_candidacy do
    includes :approve_by_clinic_director, :approve_by_sgdv
  end
end

