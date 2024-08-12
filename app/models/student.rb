class Student < ApplicationRecord
  has_many :installments, dependent: :destroy
  validates :name, presence: true
  validates :total_fee, presence: true, numericality: { greater_than: 0 }
  validates :number_of_installments, presence: true, numericality: { only_integer: true, greater_than: 0 }

  after_create :create_installments

  private

  def create_installments
    installment_amount = total_fee / number_of_installments
    number_of_installments.times do
      self.installments.create(amount: installment_amount, paid: 0, due: installment_amount, status: 'pending')
    end
  end
end
