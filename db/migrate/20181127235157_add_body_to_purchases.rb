class AddBodyToPurchases < ActiveRecord::Migration[5.2]
  def change
    add_column :purchases, :body, :string
  end
end
