class GithubWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include GithubWebhook::Processor

  # Handle push event
  def github_push(payload)
    binding.pry
  end

  # Handle create event
  def github_create(payload)
    binding.pry
  end

  private

  def webhook_secret(payload)
    "20ebf550af27f21b2883978476ffe1b3"
  end
end