module UrlHelper

  def with_subdomain(subdomain)
    subdomain = (subdomain || "")
    subdomain += "." unless subdomain.empty?
    [subdomain, request.domain, request.port_string].join
  end
  
  def url_for(options = nil)
    if options.kind_of?(Hash) && options.has_key?(:subdomain)
      options[:host] = with_subdomain(options.delete(:subdomain))
    end
    super
  end

  def domain
    request.domain
  end

  def subdomain
    if request.subdomain == "www"
      return
    else
      request.subdomain
    end 
  end

  def host
    if Rails.env == "production"
      request.host
    else
      request.host_with_port
    end    
  end

  def main_host
    if Rails.env == "production"
      "www.djcsystem.com"
    else
      "www.lvh.me:3000"
    end      
  end

  def current_website
    session[:current_website]
  end

  def website_name
    current_website.superteam_name
  end

  def website_logo
    current_website.logo 
  end

  def find_website
    if host == main_host
      Website.find_by(subdomain: "www")
    else
      web = Website.where(external_host: host).or(Website.where(subdomain: subdomain))
      if web.length > 1
        Website.where(external_host: host)
      else
        web.first
      end
    end
  end

end