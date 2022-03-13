module Bot
  class API
    def self.notify(type, params, id=-574891197)
      request({"u": id, "message": get_notification_message(type, params)})
    end

    private
    def self.request(data)
      uri = URI("http://194.67.87.132/bot_notify.php")

      Net::HTTP.start(uri.host, uri.port, :use_ssl => false ) do |http|
        request = Net::HTTP::Post.new(uri.path, 
          {'Content-Type' => 'application/json',  'Authorization' => "Token a2a4d6e32aa8ccb5829c7df8c4035ac8"})
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