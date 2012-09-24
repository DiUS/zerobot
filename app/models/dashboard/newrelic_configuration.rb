class Dashboard::NewrelicConfiguration < ActiveRecord::Base
  attr_accessible :iframe
  validates :iframe, :presence => true

  def self.build_from_performance_param!(performance)
    Dashboard::NewrelicConfiguration.new(:iframe => src(performance[:iframe]))
  end

  def self.src(iframe_url)
    iframe_url = iframe_url.match(/src=['"]([^['"]]*)['"]/)[1] if iframe_url =~ /src=/
    is_url?(iframe_url) ? iframe_url : nil
  end

  def self.is_url?(url)
    /https?:\/\/[\S]+/.match(url).present?
  end
end
