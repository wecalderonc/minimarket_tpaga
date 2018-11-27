class CreatePurchases < ActiveRecord::Migration[5.2]
  def change
    create_table :purchases do |t|
      t.reference :user
      t.reference :product
      t.integer :quantity

      t.timestamps
    end
  end
end
