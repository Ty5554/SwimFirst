class User < ApplicationRecord
  before_create :set_default_modal_shown
  BLOCKED_DOMAINS = %w[ gmail.com ]
  # スパムワード（スパム業者がよく使う単語を追加）
  BLOCKED_KEYWORDS = %w[prize winner gift free money viagra casino]
  
  # スパムURLを検出するパターン
  URL_REGEX = /https?:\/\/[^\s]+/i

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one :role, dependent: :destroy
  has_many :team_invitations
  has_many :teams, through: :team_invitations
  has_many :self_records, dependent: :destroy
  has_many :conditions, dependent: :destroy
  has_many :bodies, dependent: :destroy
  has_many :training_menus
  has_many :training_sets
  has_many :sns_credential, dependent: :destroy
  has_many :sns_credentials, dependent: :destroy
  has_many :diaries, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    [ "first_name", "last_name" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "bodies", "conditions", "role", "self_records", "team_invitations", "teams", "training_menus", "training_sets" ]
  end

  def full_name
    "#{last_name} #{first_name}"
  end

  accepts_nested_attributes_for :role
  accepts_nested_attributes_for :teams
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :omniauthable, omniauth_providers: (Rails.application.credentials.dig(:enable_google_oauth) ? [ :google_oauth2 ] : [])

  before_validation :skip_confirmation_for_google, on: :create

  class << self   # ここからクラスメソッドで、メソッドの最初につける'self.'を省略できる
    # SnsCredentialsテーブルにデータがないときの処理
    def self.without_sns_data(auth)
      user = User.where(email: auth.info.email).first

      if user.present?
        if auth.provider.present? # OAuth経由のログインの場合のみ SnsCredential を作成
          sns = SnsCredential.create(
            uid: auth.uid,
            provider: auth.provider,
            user_id: user.id
          )
        end
      else
        user = User.create(
          name: auth.info.name,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          email: auth.info.email,
          password: Devise.friendly_token(10)
        )
        if auth.provider.present? # OAuth経由のログインの場合のみ SnsCredential を作成
          sns = SnsCredential.create(
            user_id: user.id,
            uid: auth.uid,
            provider: auth.provider
          )
        end
      end
      { user:, sns: }
    end

    # SnsCredentialsテーブルにデータがあるときの処理
    def with_sns_data(auth, snscredential)
      user = User.where(id: snscredential.user_id).first
      # 変数userの中身が空文字, 空白文字, false, nilの時の処理
      if user.blank?
        user = User.create(
          name: auth.info.name,
          email: auth.info.email,
          password: Devise.friendly_token(10)
        )
      end
      { user: }
    end

    # Googleアカウントの情報をそれぞれの変数に格納して上記のメソッドに振り分ける処理
    def find_oauth(auth)
      uid = auth.uid
      provider = auth.provider

      return unless provider.present? # 通常登録の場合は処理を実行しない

      snscredential = SnsCredential.where(uid:, provider:).first
      if snscredential.present?
        user = with_sns_data(auth, snscredential)[:user]
        sns = snscredential
      else
        user = without_sns_data(auth)[:user]
        sns = without_sns_data(auth)[:sns]
      end
      { user:, sns: }
    end
  end

  def is_confirmation_period_expired?
    # メールアドレス確認メール有効期限チェック(期限はconfig/initializers/devise.rbのconfirm_withinで設定)
    self.confirmation_period_expired?
  end

  private

  def set_default_modal_shown
    self.modal_shown = false if modal_shown.nil?
  end

  def skip_confirmation_for_google
    if sns_credentials.exists?(provider: "google_oauth2")
      self.confirmed_at = Time.current
    end
  end

  def email_domain_not_blocked
    domain = email.split("@").last if email.present?
    if BLOCKED_DOMAINS.include?(domain)
      errors.add(:email, "フリーメールは使用できません")
    end
  end

  # スパムワード & URL チェック
  def block_spam_content
    attributes_to_check = [first_name, last_name, email]

    attributes_to_check.each do |value|
      next if value.blank?

      # スパムワードチェック
      if BLOCKED_KEYWORDS.any? { |word| value.downcase.include?(word) }
        errors.add(:base, "スパムワードが含まれています")
      end

      # URL のチェック
      if value.match?(URL_REGEX)
        errors.add(:base, "リンクを含む名前やメールアドレスは使用できません")
      end
    end
  end
end
