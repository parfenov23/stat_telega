class GithubWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include GithubWebhook::Processor
  require 'bot_api'
  # Handle push event пуш в ветку
  def github_push(payload)
    git_params = {pusher_name: payload["pusher"]["name"], commit: payload["head_commit"], branch: payload["ref"]}
    Bot::API.notify("push", git_params)
  end
  # Handle create event Создал новую ветку
  def github_create(payload)
  end

  def github_commit_comment(payload)
    comment =  payload["comment"]
    git_params = {
      author_name: comment["user"]["login"], 
      url: comment["html_url"], 
      body: comment["body"]
    }
    Bot::API.notify("commit_comment", git_params)
  end
  # создал пулл реквест
  def github_pull_request(payload)
    pull_request = payload["pull_request"]
    git_params = {
      pusher_name: pull_request["user"]["login"], 
      url: pull_request["html_url"], 
      title: pull_request["title"],
      body: pull_request["body"],
      branch: pull_request["head"]["ref"],
      status: pull_request["state"]
    }
    Bot::API.notify("pull_request", git_params)
  end

  #отправил ревью кода
  def github_pull_request_review(payload)
  end
  # добавил комментарий к коду
  def github_pull_request_review_comment(payload)
    comment =  payload["comment"]
    git_params = {
      author_name: comment["user"]["login"], 
      url: comment["html_url"], 
      body: comment["body"],
      branch: payload["pull_request"]["head"]["ref"]
    }
    Bot::API.notify("pull_request_review_comment", git_params)
  end

  private

  def webhook_secret(payload)
    "20ebf550af27f21b2883978476ffe1b3"
  end
end