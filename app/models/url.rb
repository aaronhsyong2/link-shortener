class Url < ApplicationRecord
  has_many :visits, dependent: :destroy
end
