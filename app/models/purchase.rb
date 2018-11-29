require 'socket'

class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :product

  def pay_request

    uri = URI.parse("https://stag.wallet.tpaga.co/merchants/api/v1/payment_requests/create")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Basic bWluaWFwcC1nYXRvMzptaW5pYXBwbWEtMTIz"
    request["Cache-Control"] = "no-cache"
    request.body = JSON.dump({
      "cost" => cost,
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
    # self.body = data["data"]["token"]
    self.update(body: data["data"]["token"])
    data
  end

  def time
    time = Time.now + (60 * 60 * 24)
    return time2 = time.iso8601
  end

  def return_url
    product = self.product.id
    purchase = self.id
    host = ENV["HOST"]

    url = "#{host}/products/#{product}/purchases/#{purchase}"
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

  def url_tpaga
    data = pay_request
    data["data"]["tpaga_payment_url"]
  end

  def cost
    self.product.price * self.quantity
  end

  def status
    body = self.body
    uri = URI.parse("https://stag.wallet.tpaga.co/merchants/api/v1/payment_requests/#{body}/info")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Basic bWluaWFwcC1nYXRvMzptaW5pYXBwbWEtMTIz"
    request["Cache-Control"] = "no-cache"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    data = JSON.parse(response.read_body)
    status = data["status"]

  end
end
