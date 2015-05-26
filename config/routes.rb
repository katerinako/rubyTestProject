SgdvBackend::Application.routes.draw do


  root :to => "members#my_profile"
  

  scope "(:locale)", :locale => /en|de|fr/ do
    match "/my_profile", :to => "members#my_profile"
    
    resources :exam_candidates  do
      get 'thank_you', :on => :collection
      get 'no_exams_available', :on => :collection
      member do
        post 'approve_by_sgdv'
        post 'approve_by_clinic_director'
      end

      resource :result
    end

    resources :attachments, :only => [:download] do
      get 'download', :on => :member
    end

    resources :exams

    resources :facilities do
      get 'autocomplete_member_with_term', :on => :collection

      member do
        post 'add_member'
        post 'remove_member'
      end
    end
    resources :equipment_types, :only => [:create, :index, :destroy]

    devise_for :members

    resources :members do
      collection do
        get 'welcome'
        get 'my_profile'
        get 'autocomplete_facility_with_term'
        
        resources :import, :only => [:new, :create, :commit] do
          collection do
            get 'show'
            post 'commit' 
          end
        end
      end

      member do
        post 'toggle_group_membership/(:group_id)', :action => "toggle_group_membership", :as => "toggle_membership"
        post 'sign_in_on_behalf'
        get 'edit_password', :action => "edit_password"
        put 'update_password', :action => "update_password"
        post 'add_facility'
        post 'remove_facility'
        post 'remove_designation'
      end

    end

    match 'not_allowed' => 'members#not_allowed', :as => "member_not_allowed"

    resources :member_candidates do
      get 'thank_you', :on => :collection
      get 'determine', :on => :member
      put 'set_status', :on => :member
    end

    resources :posts do
      collection do
        get 'new_post_with_facility', :as => :new_post_with_facility
        get 'autocomplete_facility_with_term'
        get 'autocomplete_member_with_term'
      end

    end

    resources :designations, :except => [:index, :show] do
      collection do
        get 'autocomplete_member_with_term'
        get 'autocomplete_organizational_unit_with_term'
      end
    end
    resources :designation_types, :only => [:create, :index, :destroy]

    resources :memberships, :except => [:index] do
      resources :invoices,  :except => [:show] do
        member do
          post 'mark_sent'
          post 'mark_paid'
        end
      end
    end

    resources :membership_categories

    resources :groups

    resources :organizational_units do
      post 'remove_designation', :on => :member
    end

    resources :payments, :only => [:index]

    resource :addressbook do
      member do
        get 'autocomplete_personal'
        get 'autocomplete_business'
        get 'autocomplete_equipment'
        get 'autocomplete_function'
        get 'autocomplete_postal_canton'
        get 'autocomplete_personal'
        get 'autocomplete_specialization'
      end
    end
  end
end
