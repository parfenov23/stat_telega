class GithubWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include GithubWebhook::Processor

  # Handle push event
  def github_push(payload)
    p payload
  end

  # Handle create event
  def github_create(payload)
    p payload
  end

  private

  def webhook_secret(payload)
  end
end