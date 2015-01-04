class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships #source is default rails convention
  has_many :reposts, foreign_key: "reposter_id", dependent: :destroy

	attr_accessor :remember_token, :activation_token, :reset_token
	before_save {email.downcase!}
  before_create :create_activation_digest

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :name, presence: true, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX },
		uniqueness: {case_sensitive: false}

	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true

	# Returns the hash digest of the given string.
  	def User.digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token to be used for cookies
  	def User.new_token
      SecureRandom.urlsafe_base64
    end

    # Remember a user in the database by storing a hashed token alongside it
    def remember
      self.remember_token = User.new_token
      update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Check if the token matches the digested one
    def authenticated?(attribute, token)
      digest = self.send("#{attribute}_digest")
    	return false if digest.nil?
		  BCrypt::Password.new(digest).is_password?(token)
    end

    # deletes the remember token, forgetting the user
  	def forget
  	  update_attribute(:remember_token, nil)
  	end

    def activate
      update_columns(activated: true, activated_at: Time.zone.now)
    end

    def send_activation_email
      UserMailer.account_activation(self).deliver_now
    end

    def create_reset_token
      self.reset_token = User.new_token
      update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    def send_password_reset_email
      UserMailer.password_reset(self).deliver_now
    end

    def password_reset_expired? 
      reset_sent_at < 2.hours.ago
    end

    def feed
      following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
      reposts = "SELECT micropost_id FROM reposts
                     WHERE reposter_id IN (#{following_ids})"                     
      Micropost.where("user_id IN (#{following_ids})
                     OR id IN (#{reposts})
                     OR user_id = :user_id", user_id: id)
    end

    def follow(other_user)
      active_relationships.create(followed_id: other_user.id)
    end

    def unfollow(other_user)
      active_relationships.find_by(followed_id: other_user.id).destroy
    end

    #true if the current user is following the other user
    def following?(other_user)
      following.include?(other_user)
    end

    def repost(micropost)
      reposts.create(micropost_id: micropost.id)
    end

    private

      def create_activation_digest
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
      end
end
