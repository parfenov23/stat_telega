class HomeController < ApplicationController
  require 'remote_ip'

  def index
    return go_to_link("https://telega.io") if params[:id].blank?

    current_ip = Rails.env.production? ? request.ip : ""
    result = RemoteIp.info(current_ip)

    short_link = ShortLink.where(link_id: params[:id]).first
    return go_to_link("https://telega.io") if short_link.blank?

    short_link.save_stat!(result)
    return go_to_link(short_link.link)
  end

  def stats
    link_ids = params[:links].map{|link| link.gsub("https://tglink.io/", "")}
    stat_short_links = StatShortLink.where(short_link_id: ShortLink.where(link_id: link_ids).ids)
    all_count = stat_short_links.sum(:count)

    render json: {all_count: all_count, count: stat_short_links.count}
  end

  def create_link
    links = params[:links].map{|link| {link: link, channel_id: params[:channel], order_channel_id: params[:order_channel_id]}}
    short_links = ShortLink.create(links)

    render json: {result: short_links.map{|sl| {link: sl.link, id: sl.link_id} }}
  end

  def update_short_links
    short_links = ShortLink.where(link_id: params[:ids])
    short_links.update(order_channel_id: params[:order_channel_id])

    render json: {success: true}
  end

  def callback_notify_bot
    render json: {success: true, params: params.as_json}
  end

  def jira_notify
    render json: {success: true}
  end

  private 

  def go_to_link(link)
    redirect_to link
  end
end