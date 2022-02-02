class JiraWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  require 'jira'
  require 'bot_api'

  def index

  end

  def notify
    params_task = params[:issue]
    params_task_fields = params_task[:fields]
    get_tg_account = Jira.get_user_telegram(params_task_fields[:assignee][:accountId])
    get_tg_chat = Jira.get_chat_from_project(params_task_fields[:project][:id].to_i)
    Bot::API.notify("update_task", {
      user_account: get_tg_account, 
      id: params_task[:key], 
      column: params_task_fields[:status][:name],
      desc: params_task_fields[:description],
      title: params_task_fields[:summary]
    }, get_tg_chat)
    render json: {success: true}
  end
end