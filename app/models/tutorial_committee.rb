class TutorialCommittee < ActiveRecord::Base
  attr_accessible :studentname, :descr, :year, :career_attributes
  validates_presence_of :studentname,  :year
  validates_numericality_of :id, :user_id, :allow_nil => true, :greater_than => 0, :only_integer => true

  belongs_to :career
  accepts_nested_attributes_for :career
  belongs_to :institutioncareer # FIX IT: Remove this relationship until next release.
                                # We need institutioncareers table to support
                                # migrations from previous versions of salva databases.

  belongs_to :user
  belongs_to :registered_by, :class_name => 'User', :foreign_key => 'registered_by_id'
  belongs_to :modified_by, :class_name => 'User', :foreign_key => 'modified_by_id'

  default_scope :order => ('tutorial_committees.year DESC, tutorial_committees.studentname ASC')
  scope :degree_id, lambda { |id| joins(:career).where("careers.degree_id = ?", id) }
  scope :adscription_id, lambda { |id| joins(:user => :user_adscription).where(:user => { :user_adscription => { :adscription_id => id} }) }

  search_methods :degree_id, :adscription_id

  def to_s
    ["#{studentname} (estudiante)", career.to_s, year].compact.join(', ')
  end
end
