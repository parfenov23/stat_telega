module Bot
  class API
    def self.notify(type, params, id=-574891197)
      request("https://telega.in/tg_api_bots/notify/send_message", {
        type: :post,
        data: {
          u: id, 
          message: get_notification_message(type, params),
          key: "48cb524b0e80838b67d1"
        }
      })
    end

    private

    def self.request(path, params={})
      is_log = Rails.env.development? || params[:log] == true
      logger = Logger.new(is_log ? STDOUT : nil)

      uri = URI(path)
      agent = params[:type] == :post ? Net::HTTP::Post : Net::HTTP::Get
      request = agent.new(uri)
      request["Content-Type"] = 'application/json'
      (params[:headers] || {}).each do |k, v|
        request[k] = v
      end
      request.body = params[:data].compact.to_json if params[:data].present?
      request.set_form_data(params[:form].compact) if params[:form].present?
      req_options = {
        use_ssl: uri.scheme == "https",
      }

      logger.info "Request url: #{uri}, type: #{params[:type] || 'get'}, payload: #{params[:data] || params[:form]}, headers: #{params[:headers]}" if is_log

      time_hash = Rails.env.production? && params[:cache] == true ? 5 : 0
      id_cache = Digest::MD5.hexdigest(path)
      Rails.cache.fetch(id_cache, expires_in: time_hash.minute, race_condition_ttl: time_hash.minute) do
        http_response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
        logger.info "Response: #{http_response.body}" if is_log
        JSON.parse(http_response.body).deep_symbolize_keys rescue {}
      end
    end

    def self.get_notification_message(type, params)
      view = ActionView::Base.new(ActionController::Base.view_paths, {})
      message = view.render(template: "git_webhook/#{type}", locals: params)
      message
    end
  end
end