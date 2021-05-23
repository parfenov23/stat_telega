module Bot
  class API
    def self.notify(type, params)
      request({"u": "-574891197", "message": get_notification_message(type, params)})
    end

    private
    def self.request(data)
      uri = URI("http://193.176.79.94/bot_notify.php")

      Net::HTTP.start(uri.host, uri.port, :use_ssl => false ) do |http|
        request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json',  'Authorization' => "Token 8a8abd57da84ca5c20964ea23c28c3cf"})
        request.form_data = data
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