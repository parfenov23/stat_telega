class RemoteIp

  def self.info(ip)
    result = JSON.parse(Net::HTTP.get(URI.parse("https://json.geoiplookup.io/#{ip}")).as_json).deep_symbolize_keys

    {
      ip: result[:ip],
      country_code: result[:country_code],
      country_name: result[:country_name],
      region: result[:region]
    }
  end
end
