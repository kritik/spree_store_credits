class StoreCredit < ActiveRecord::Base
  validates :amount, :presence => true, :numericality => true
  validates :reason, :presence => true
  validates :user, :presence => true
  
  belongs_to :user
  
  def self.payed_order_credit_name order = nil
    "earned by with order #{order.id}"
  end
end
