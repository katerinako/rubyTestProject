class OrganizationalUnit < ActiveRecord::Base
  extend DistinctFields

  belongs_to :parent, :class_name => 'OrganizationalUnit'
  has_many :children,
           :class_name => 'OrganizationalUnit', :foreign_key => :parent_id,
           :dependent => :destroy,
           :autosave => true,
           :order => :name

  has_many :designations, :dependent => :destroy, :autosave => true

  validates :name, :presence => true

  default_scope :order => 'name'

  scope :top_level, lambda { where(:parent_id => nil).order(:name) }
  scope :with_term, lambda { |term| where(:name.matches => "%#{term}%") }

  before_save :copy_tag_from_parent

  class << self
    def secretary
      sgdv = top_level.where(:name.matches => "SGDV%").first
      sgdv.designations.current.where(:kind.matches => "%Generalsekret%").first.member rescue nil
    end
    
    def admin
      sgdv = top_level.where(:name.matches => "SGDV%").first
      sgdv.designations.current.where(:kind => "Admin").first.member rescue nil

    end
  end
  private 

  def copy_tag_from_parent
    self.tag = parent.tag if parent.present?
  end
end
