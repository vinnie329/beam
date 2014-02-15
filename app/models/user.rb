class User < ActiveRecord::Base

	has_many :posts, dependent: :destroy
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy
	has_many :followed_users, through: :relationships, source: :followed

	has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
	has_many :followers, through: :reverse_relationships

	before_save { self.email = email.downcase }
	before_create :create_remember_token
	
	#As long as there is a password_digest column in the database, this one method gives us a secure way to create and authenticate new users. 				  
	has_secure_password

	validates :name, presence: true, 
					 uniqueness: { case_sensitive: false }, 
					 length: { maximum: 50 }
	
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, 
					  format: { with: VALID_EMAIL_REGEX }, 
					  uniqueness: { case_sensitive: false }

	validates :password, length: { minimum: 6 }

	validates :bio, length: { maximum: 140 }

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def following?(other_user)
  	self.relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
  	self.relationships.create(followed_id: other_user.id)
  end

  def unfollow!(other_user)
  	self.relationships.find_by(followed_id: other_user.id).destroy
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

end
