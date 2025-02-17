class User < ApplicationRecord
  before_create :set_default_modal_shown

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
         :omniauthable, omniauth_providers: %i[google_oauth2]

  before_validation :skip_confirmation_for_google, on: :create

  class << self   # ここからクラスメソッドで、メソッドの最初につける'self.'を省略できる
    # SnsCredentialsテーブルにデータがないときの処理
    def without_sns_data(auth)
      user = User.where(email: auth.info.email).first

      if user.present?
        sns = SnsCredential.create(
          uid: auth.uid,
          provider: auth.provider,
          user_id: user.id
        )
      else   # User.newの記事があるが、newは保存までは行わないのでcreateで保存をかける
        user = User.create(
          name: auth.info.name,   # デフォルトから追加したカラムがあれば記入
          first_name: auth.info.first_name,   # デフォルトから追加したカラムがあれば記入
          last_name: auth.info.last_name,   # デフォルトから追加したカラムがあれば記入
          email: auth.info.email,
          password: Devise.friendly_token(10)   # 10文字の予測不能な文字列を生成する
        )
        sns = SnsCredential.create(
          user_id: user.id,
          uid: auth.uid,
          provider: auth.provider
        )
      end
      { user:, sns: }   # ハッシュ形式で呼び出し元に返す
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
end
