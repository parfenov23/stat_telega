module Bot
  class API
    def self.notify(message)
      request({"u": "-574891197", "message": message})
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
  end
end