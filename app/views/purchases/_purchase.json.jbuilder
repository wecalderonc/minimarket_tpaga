json.extract! purchase, :id, :user, :product, :quantity, :created_at, :updated_at
json.url purchase_url(purchase, format: :json)
