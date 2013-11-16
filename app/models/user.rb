class User < ActiveRecord::Base
  attr_accessible :provider, :uid, :name, :email

  validates :provider, :allow_blank => true, :inclusion => {
    :in      => %w(github),
    :message => "%{value} is not a valid provider" }

  validates :username, :presence => true

  validates :state, :presence => true

  validates :email, :allow_blank => true, :format => {
    :with    => /@/, # more is probably overkill
    :message => 'Invalid email address' }

  scope :visitors,    -> { where(:state => 'visitor') }
  scope :applicants,  -> { where(:state => 'applicant') }
  scope :members,     -> { where(:state => 'member') }
  scope :key_members, -> { where(:state => 'key_member') }

  state_machine :state, :initial => :visitor do
    event :make_applicant do
      transition :visitor => :applicant
    end

    event :make_member do
      transition :applicant => :member
    end

    event :make_key_member do
      transition :member => :key_member
    end

    state :visitor
    state :applicant
    state :member
    state :key_member
  end

  def member_or_key_member?
    member? || key_member?
  end

  def gravatar_url(size = 200)
    hash = email ? Digest::MD5.hexdigest(email.downcase) : nil
    "http://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end

  class << self
    def create_with_omniauth(auth)
      new.tap do |user|
        auth = GithubAuth.new(auth)

        user.provider = auth.provider
        user.uid      = auth.uid
        user.username = auth.username
        user.name     = auth.name
        user.email    = auth.email

        user.save!
      end
    end

    def find_provisioned(auth)
      auth = GithubAuth.new(auth)

      where(:provider => auth.provider, :username => auth.username).first
    end

    def provision_with_state(username, state, attrs = {})
      new.tap do |user|
        user.provider = DEFAULT_PROVIDER
        user.username = username
        user.state    = state

        user.save!
      end
    end
  end

  private

  DEFAULT_PROVIDER = 'github'
end
