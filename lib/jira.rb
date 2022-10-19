class Jira
  def self.get_chat_from_project(project_id)
    case project_id
    when 10000
      -814657630
    when 10002
      -664080136
    end
  end

  def self.get_user_telegram(user_id)
    case user_id
    when "5fdb6acf6420890141408261"
      "@stomom"
    when "557058:1425bca5-cb5f-4802-b822-0ebfb7f24e7d"
      "@parfenov407"
    when "6315a4d29794410874c6b9fc"
      "@Dinara_Av"
    when "5ed3b6622bea5a0c2f0fd883"
      "@pwgen777"
    when "60be503700bdd900684a8912"
      "@summnas"
    when "5e8acb6b71d2150b82da5e1c"
      "@maximfringe"
    when "70121:97c89137-fb3c-4391-804d-d99e591c2042"
      "@DoggyDogFPV"
    end
  end
end