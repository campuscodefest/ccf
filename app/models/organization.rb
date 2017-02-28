class Organization < ActiveRecord::Base
  attr_accessible :auto_verify, :auto_verify_domains, :description, :name, :subdomain, :website, :organization_logo, :remove_organization_logo,
                  :slack_webhook_url, :public_access

  mount_uploader :organization_logo, OrganizationLogoUploader

  has_many :events
  has_many :projects
  has_many :users, :class_name => "OrganizationUser"

  validates :name, :subdomain, presence: true
  validates :subdomain, uniqueness: true

  scope :public_accessible, ->{ where(public_access: true) }

  def self.current_id=(id)
    Thread.current[:current_id] = id
  end
  
  def self.current_id
    Thread.current[:current_id]
  end

  def add_creator(user)
    new_user = users.new(user: user, verified: true)
    new_user.admin = true
    new_user.save
  end

  def admin?(user)
    return true if user.admin?

    organization_user = users.where(user_id: user).first
    organization_user.present? && organization_user.admin?
  end

  def verified?(user)
    organization_user = users.where(user_id: user).first
    organization_user.present? && organization_user.verified?
  end

  def member?(user)
    users.where(user_id: user).first.present?
  end
end
