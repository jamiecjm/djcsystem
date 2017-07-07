class Subdomain
  def self.matches?(request)
    request.subdomain.present? && host != main_host
  end
end