class User < ActiveRecord::Base

  attr_accessor :remember_token

  before_save { self.email = email.downcase }

  validates :name,  presence: true, length: { maximum: 50 }

  # Expression rationnelle qui match avec le format d'un email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    # l'unicité de l'email n'est pas sensible à la casse
                    uniqueness: { case_sensitive: false }

  has_secure_password

  # Autorise l'absence du mot de passe lors de l'édition des données de l'utilisateur.
  # Pas d'inquiétude à avoir pour l'inscription, la méthode has_secure_password
  # vérifie la présence du mot de passe lors de la création de l'objet.
  validates :password, length: { minimum: 6 }, allow_blank: true

  # => Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # => Renvoie 1 random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # => Remembers a user in the database for use in persistent sessions.
  def remember
    # Sans self on aurait créé une variable locale remember_token. Utiliser self permet de modifier l'attribut - remember_token de l'utilisateur (user)
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # renvoie true si remember_token match avec remember_digest
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Oublier un utilisateur en assignant nil à l'attribut remember_digest
  def forget
    update_attribute(:remember_digest, nil)
  end

end