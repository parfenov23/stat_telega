class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:callback_notify_bot]

  def index
    @all_channels = Channel.where(category: nil)
    offset = rand(@all_channels.count)
    @channel = @all_channels.offset(offset).first
    if @channel.present?
      @link = @channel.link
      agent = Mechanize.new
      if @link.scan("joinchat").blank?
        begin
          @current_link = @channel.link.gsub("https://t.me/", "https://t.me/s/")
          page = (agent.get(@current_link) rescue nil)
          if page.present?
            @info = page.search(".tgme_channel_info").to_s
            @posts = page.search(".tgme_channel_history").to_s
            
            @info = page.search(".tgme_page").to_s if @info.blank?
          end
        rescue
        end
      else
        begin
          page = agent.get(@channel.link)
          @info = page.search(".tgme_page").to_s
        rescue
        end
      end
    end
  end

  def update
    Channel.find(params[:id]).update(category: params[:category], user_id: current_user.id, processed: true)
    redirect_back(fallback_location: root_path)
  end

  def history
    @channels = current_user.channels.where(archive: false).order("updated_at DESC")
  end

  def all
    @count_no_processed = Channel.where(processed: false).count
    @channels = Channel.where(processed: true)
    @channels = @channels.where(user_id: params[:users]) if params[:users].present?
    @channels_archive = @channels.where(archive: true)
    @channels = @channels.where(archive: false)
  end

  def create_channels
    all_links = params[:channels].split("\r\n")
    all_links.each do |link|
      Channel.find_or_create_by(link: link)
    end
    redirect_to "/"
  end

  def all_to_archive
    Channel.where(processed: true, archive: false, user_id: params[:users]).update(archive: true)
    redirect_back(fallback_location: root_path)
  end

  def import_all
    @channels = Channel.where(processed: true, archive: false, user_id: params[:users])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def callback_notify_bot
    render json: {success: true, params: params.as_json}
  end
end