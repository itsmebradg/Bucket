class User < ActiveRecord::Base

	attr_accessor   :password
	attr_accessible :name, :email, :password, :password_confirmation
	
	has_many :microposts, :dependent => :destroy
	
	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	
	validates :name,  :presence => true,
	                  :length => { :maximum => 50 }
					  
	validates :email, :presence   => true,
	                  :length     => { :maximum => 100 },
					  :format     => { :with => email_regex },
					  :uniqueness => { :case_sensitive => false }

	validates :password, :presence => true,
	                     :confirmation => true,
						 :length => { :within => 6..40 }
						 
	before_save :encrypt_password
	
	def has_password?(submitted_password)
		encrypted_password == encrypt(submitted_password)
	end
	
	class << self
		def authenticate(email, submitted_password)
			user = find_by_email(email)
			(user && user.has_password?(submitted_password)) ? user : nil
		end
		
		def authenticate_with_salt(id, cookies_salt)
			user = find_by_id(id)
			(user && user.salt == cookies_salt) ? user : nil
		end
	end
	
	private
	
		def encrypt_password
			self.salt = make_salt if new_record?
			self.encrypted_password = encrypt(password)
		end
		
		def encrypt(string)
			secure_hash("#{salt}--#{string}")
		end
		
		def make_salt
			secure_hash("#{Time.now.utc}--#{password}")
		end
		
		def secure_hash(string)
			Digest::SHA2.hexdigest(string)
		end
end