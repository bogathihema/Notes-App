class User < ApplicationRecord
  has_secure_password
  has_many :notes, dependent: :destroy
  validates :username, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
end
