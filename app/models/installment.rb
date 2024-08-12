class Installment < ApplicationRecord
  belongs_to :student

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :paid, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :due, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
  # validate :valid_paid_amount, on: :update

  private
    def valid_paid_amount
      if paid < 1 || paid > student.total_fee
        errors.add(:paid, "must be between ₹1 and ₹#{student.total_fee}.")
      end
    end
end
