class ShortLink < ApplicationRecord
  has_many :stat_short_links, dependent: :destroy
  before_validation :generate_link_id
  
  def save_stat!(result)
    stat_short_link = stat_short_links.find_or_create_by(ip: result[:ip])
    stat_short_link.additional_info = result
    stat_short_link.count += 1
    stat_short_link.save
  end

  private

  def generate_link_id
    self.link_id = SecureRandom.hex(6) if link_id.blank?
  end
end
