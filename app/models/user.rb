class User < ApplicationRecord
  before_create :set_default_modal_shown
  BLOCKED_DOMAINS = %w[
    gmail.com yahoo.com outlook.com hotmail.com icloud.com
    mail.ru yandex.ru protonmail.com rambler.ru qq.com 163.com
  ]
  # スパムワード（スパム業者がよく使う単語を追加）
  BLOCKED_KEYWORDS = %w[prize winner gift free money viagra casino lottery bonus]
  
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
  # 🔹 追加: バリデーションを明示的に定義
  validates :first_name, :last_name, presence: true
  validate :email_domain_not_blocked
  validate :block_spam_content
  validate :block_suspicious_email_format
  validate :prevent_duplicate_registrations

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
    return if email.blank?

    domain = email.split("@").last
    if BLOCKED_DOMAINS.include?(domain)
      errors.add(:email, "このドメインのメールアドレスは使用できません")
    end
  end

  # スパムワード & URL チェック
  def block_spam_content
    attributes_to_check = [first_name, last_name, email, password]

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

  def block_suspicious_email_format
    return if email.blank?

    # 数字やランダムな文字列のみのメールアドレスをブロック
    if email.match?(/\A[a-zA-Z0-9_.+-]+@(xn--|[0-9]+|mailinator|tempmail)\.[a-z]{2,}\z/)
      errors.add(:email, "無効なメールアドレスです")
    end
  end

  # 🔹 **新規追加: 短時間での大量登録を防ぐ**
  def prevent_duplicate_registrations
    if User.where(email: email).where("created_at > ?", 5.minutes.ago).exists?
      errors.add(:email, "短時間に複数回の登録はできません")
    end
  end
end
