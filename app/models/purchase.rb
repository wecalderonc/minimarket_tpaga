require 'socket'

class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :product

  def pay_request
    @purchase = Purchase.last
    uri = URI.parse("https://stag.wallet.tpaga.co/merchants/api/v1/payment_requests/create")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Basic bWluaWFwcC1nYXRvMzptaW5pYXBwbWEtMTIz"
    request["Cache-Control"] = "no-cache"
    request.body = JSON.dump({
      "cost" => "12000",
      "purchase_details_url" => return_url,
      "voucher_url" => return_url,
      "idempotency_token" => idempotency_token,
      "order_id" => order_id,
      "terminal_id" => "sede_teusaquillo",
      "purchase_description" => "Compra en Tienda WIlliamTPAGA",
      "user_ip_address" => ip,
      "expires_at" => time
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    data = JSON.parse(response.read_body)
    url = data["tpaga_payment_url"]
    data
  end

  def time
    time = Time.now + (60 * 60 * 24)
    return time2 = time.iso8601
  end

  def return_url
    product = self.product.id
    purchase = self.id
    url = "https://localhost:3000/products/#{product}/purchases/#{purchase}"
  end

  def order_id
    purchase = self.id
    400000 + purchase
  end

  def idempotency_token
    purchase = self.id
    80000000000 + purchase * 1234
  end

  def ip
    Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
  end
end