class Role < ApplicationRecord
  belongs_to :user
  enum :role, { coach: 0, athlete: 1 }
  validates :role, presence: true
  validates :user, presence: true

  after_initialize :set_default_role, if: :new_record?

  def self.roles_i18n
    roles.map { |key, _| [I18n.t("activerecord.attributes.role.roles.#{key}"), key] }
  end

  private

  def set_default_role
    self.role ||= :athlete.to_s
  end
end
