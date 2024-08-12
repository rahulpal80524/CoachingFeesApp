class CreateInstallments < ActiveRecord::Migration[7.1]
  def change
    create_table :installments do |t|
      t.references :student, null: false, foreign_key: true
      t.decimal :amount
      t.decimal :paid
      t.decimal :due
      t.string :status

      t.timestamps
    end
  end
end
