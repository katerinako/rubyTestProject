class Membership < ActiveRecord::Base
  STATUS_LABELS          = {
    :fmh_member          => "FMH Member",
    :eadv_member         => "EADV Member",
    :fb_diploma_fmh_sgdv => "FB Diploma FMH SGDV",
    :sdntt_participant   => "SDNTT Participant"
  }

  belongs_to :member
  belongs_to :membership_category
  has_many :invoices, :dependent => :destroy, :autosave => true

  validates_presence_of :from_date, :membership_category_id, :nomination

  validates :from_date, :date => true
  validates :to_date, :date => {:after => :from_date}, :allow_blank => true

  default_scope order(:from_date.desc, :to_date.asc)

  scope :current, lambda {
    now = Date.today
    as_of_date(now)
  }

  scope :as_of_date, lambda { |date|
    where(:from_date.lte % date & (:to_date.gte % date | :to_date.eq % nil))
  }
  scope :past, lambda {
    now = Date.today
    where(:to_date.not_eq => nil, :to_date.lt => now)
  }

  scope :sgdv,
    joins(:membership_category).
    where(:membership_category => {:kind => "SGDV"})

  scope :dermarena,
    joins(:membership_category).
    where(:membership_category => {:kind => "Dermarena"})

  scope :other,
    joins(:membership_category).
    where(:membership_category => {:kind => "Other"})


  scope :with_status, lambda { |status|
    status ||= :invoice_due
    date = (status.to_sym == :invoice_soon ? 3.months.since(Date.today) : Date.today)

    puts "in with_status: date: #{date}, status: #{status}"
    case status.to_sym
    when :invoice_due, :invoice_soon
      select("distinct memberships.*").
      as_of_date(date).
      includes(:invoices).
      where("(not exists (select * from invoices where invoices.membership_id = memberships.id)) or " +
            "(invoices.invoice_sent = 0 and invoices.period_from_date <='#{date}' and invoices.period_to_date >= '#{date}')")
                  # {:invoices => {:invoice_sent         => false,
                  #               :period_from_date.lte => date,
                  #               :period_to_date.gte   => date}})

    when :payment_due
      select("distinct memberships.*").
      joins(:invoices).
      where(:invoices => {:invoice_paid => false})
    end
  }

  scope :with_kind, lambda { |kind|
    if kind == "all" or kind.blank?
      scoped
    else
      joins(:membership_category).where(:membership_category => {:kind => kind})
    end
  }

  scope :with_personal, lambda { |term|
    relation = select("distinct memberships.*").
               joins(:member)

    term.split(/\s+/).reduce(relation) do |relation, word|
      word = "%#{word}%"

      relation.where(:member =>  {:first_name.matches => word} |
                                 {:last_name.matches => word}  |
                                 {:middle_name.matches => word} |
                                 {:title.matches => word})
    end
  }

  search_methods :with_status, :with_kind, :with_personal

  def description
    "Membership Category #{membership_category.name} (#{membership_category.kind})"
  end

  def full_description
    "#{member.name}: #{description}"
  end

  def fee_invoiced?(date=Date.today)
    invs = invoices.as_of_date(date)

    not invs.empty? and invs.all? { |invoice| invoice.invoice_sent? }
  end

  def invoices_paid?
    invs = invoices

    invs.all? { |invoice| invoice.invoice_paid? }
  end

  def invoice_due?(months=3)
    date = months.months.since(Date.today)
    due = (not fee_invoiced?(date) and membership_active?(date))
    due
  end

  def membership_active?(date=Date.today)
    active = from_date <= date && (to_date == nil || date <= to_date)
    active
  end
end
