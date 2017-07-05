class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :timeoutable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]
  
  attr_accessor :login

  include PgSearch
  pg_search_scope :search_by_name, :against => [:prefered_name,:name]

  has_many :sales, :through => :salevalues
  has_many :salevalues, dependent: :destroy
  belongs_to :team, optional: true

  has_ancestry :orphan_strategy => :rootify

  before_validation :titleize_name
  before_validation :set_team
  
  validates_confirmation_of :password
  validates :prefered_name, uniqueness: {message: "has been taken. Check with you leader whether you have an account."}, unless: Proc.new { |a| a.team_id.blank?}
  validates :email, presence: true, unless: Proc.new {|a| a.team_id.blank?}

  enum location: ["KL","JB","Penang","Melaka"]
  enum position: ["REN","Team Leader","Team Manager","admin"]

  
  def active_sv
    Sale.where.not(status: 'Canceled').joins(:salevalues).where("salevalues.user_id = #{self.id}")
  end

  def TotalNetValue
    self.active_sv.sum(:nett_value)
  end

  def TotalComm
    self.active_sv.sum(:comm)
  end

  def TotalSPA
    self.active_sv.sum(:spa)
  end

  def TotalSales
    self.sales.not_canceled.count
  end

  # def recalculate
  #   self.update_columns(total_spa: self.TotalSPA,total_nett_value: self.TotalNetValue,total_comm: self.TotalComm,total_sales: self.TotalSales)
  # end

  def self.approved
    self.where(approved?: true)
  end

  def leader
    self.team.leader
  end

  def leader?
    Team.all.pluck(:leader_id).include?(self.id)
  end

  def sub_tree_sales
    Sale.joins(:users).where("users.id" => self.subtree)
  end

  def sub_tree_salevalues
    Salevalue.joins(:user).where("users.id" => self.subtree)
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.prefered_name || self.email
  end

  def self.merge
    name_arrays = self.select(:prefered_name).group(:prefered_name).having("count(*) > 1").pluck(:prefered_name)
    name_arrays.each do |name|
      duplicates = self.where(prefered_name: name).order('id')
      duplicates[1].salevalues.update_all(user_id: duplicates[0].id)
      duplicates[1].destroy
    end
  end

  def admin?
    self.admin
  end

  private

  def titleize_name
    self.name = self.name.titleize.strip if self.name.present?
    self.prefered_name = self.prefered_name.titleize.strip if self.prefered_name.present?
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(prefered_name) = lower(:value) OR lower(email) = lower(:value)", { :value => login }]).first
    elsif conditions.has_key?(:prefered_name) || conditions.has_key?(:email)
      where(conditions.to_hash).first
    end
  end

  def email_required?
    !team_id.nil?
  end

  def set_team
    if self.parent.present? && !self.leader?
      self.team_id = self.parent.team_id 
    end
  end


end
