module Bot
  class API
    def self.notify(type, params, id=-574891197)
      request({u: id, message: get_notification_message(type, params)})
    end

    private
    def self.request(data)
      uri = URI("http://telega.in/tg_api_bots/notify/send_message")

      Net::HTTP.start(uri.host, uri.port, :use_ssl => false ) do |http|
        request = Net::HTTP::Post.new(uri.path, 
          {'Content-Type' => 'application/json'})
        request.form_data = data.merge({key: "48cb524b0e80838b67d1"})
        response = http.request request
      end
    end

    def self.get_notification_message(type, params)
      view = ActionView::Base.new(ActionController::Base.view_paths, {})
      message = view.render(template: "git_webhook/#{type}", locals: params)
      message
    end
  end
end