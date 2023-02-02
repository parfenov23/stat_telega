class RunHotSessionsJob < ApplicationJob
  # require 'api_telegram'
  # require 'bot_api'
  # queue_as :run_hot_sessions_job

  # def perform(path)
  #   result = ApiTelegram.sessions_warming_up(path + "/")
  #   file_name = SecureRandom.hex(10)

  #   zip_folder(file_name)

  #   hot_sessions_params = {
  #     count: result.length, 
  #     hot_count: result.select{|k, v| v > 0}.length, 
  #     url: "http://tglink.io/uploads/hot_download/#{file_name}.zip"
  #   }
  #   Bot::API.notify("hot_sessions", hot_sessions_params, -895037612)
  # end

  # def zip_folder(file_name)
  #   folder_path = "#{Rails.root}/public/uploads/hot_session"
  #   entries = Dir.entries(folder_path) - %w[. ..]

  #   ::Zip::File.open("#{Rails.root}/public/uploads/#{file_name}.zip", ::Zip::File::CREATE) do |zip_file|
  #     entries.each do |entry|
  #       zip_file.add(entry, File.join(folder_path, entry))
  #     end
  #   end

  #   entries.each do |folder|
  #     path_to_directory = "#{folder_path}/#{folder}"
  #     FileUtils.remove_dir(path_to_directory) if File.directory?(path_to_directory)
  #   end
  # end
end
