require 'net/http'
require 'net/https'
require 'uri'
require 'json'

class PurchasesController < ApplicationController
  before_action :set_purchase, only: [:show, :edit, :update, :destroy]

  # GET /purchases
  # GET /purchases.json
  def index
    @product = Product.find(params[:product_id])
    @purchases = Purchase.all

  end

  # GET /purchases/1
  # GET /purchases/1.json
  def show
    @product = Product.find(params[:product_id])
  end

  # GET /purchases/new
  def new
    @product = Product.find(params[:product_id])
    @purchase = Purchase.new
  end

  # GET /purchases/1/edit
  def edit
    @product = Product.find(params[:product_id])
  end

  # POST /purchases
  # POST /purchases.json
  def create
    @product = Product.find(params[:product_id])
    @purchase = Purchase.new(purchase_params)

    @purchase.quantity = @purchase.quantity
    @purchase.user = current_user
    @purchase.product = @product

    respond_to do |format|
      if @purchase.save
        format.html { redirect_to product_purchase_path(@product, @purchase), notice: 'Purchase was successfully created.' }
        format.json { render :show, status: :created, location: @purchase }
      else
        format.html { render :new }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchases/1
  # PATCH/PUT /purchases/1.json
  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        format.html { redirect_to @purchase, notice: 'Purchase was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase }
      else
        format.html { render :edit }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchases/1
  # DELETE /purchases/1.json
  def destroy
    @purchase.destroy
    respond_to do |format|
      format.html { redirect_to purchases_url, notice: 'Purchase was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def pay_request

      uri = URI.parse("https://stag.wallet.tpaga.co/merchants/api/v1/payment_requests/create")
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/json"
      request["Authorization"] = "Basic bWluaWFwcC1nYXRvMzptaW5pYXBwbWEtMTIz"
      request["Cache-Control"] = "no-cache"
      request.body = JSON.dump({
        "cost" => "12000",
        "purchase_details_url" => "https://example.com/compra/348920",
        "voucher_url" => "https://example.com/comprobante/348920",
        "idempotency_token" => "ea0c78c5-e95a-47c4-b7f9-25a9015f1d39",
        "order_id" => "348920",
        "terminal_id" => "sede_45",
        "purchase_description" => "Compra en Tienda X",
        "purchase_items" => [
          {
            "name" => "Aceite de girasol",
            "value" => "13.390"
          },
          {
            "name" => "Arroz X 80g",
            "value" => "4.190"
          }
        ],
        "user_ip_address" => "61.1.224.56",
        "expires_at" => "2018-12-05T20:16:57.549653+00:00"
      })

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      data = JSON.parse(response.read_body)
      #data = JSON.parse (response)
      url = data["tpaga_payment_url"]

      redirect_to url
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase
      @purchase = Purchase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_params
      params.require(:purchase).permit(:quantity)
    end

  end
