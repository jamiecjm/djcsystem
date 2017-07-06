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
    request.subdomain
  end

  def host
    if Rails.env == "production"
      request.host
    else
      request.host_with_port
    end    
  end

  # find current subdomain
  def current_website
    Website.revert_database
    web = Website.find_by(external_host: host)
    if web.nil?
      Website.find_by(subdomain: subdomain)
    else
      web
    end
  end

  def website_settings
    session[:website_settings]
  end

  def website_name
    website_settings["superteam_name"]
  end

  def website_logo
    session[:logo_url]
  end

  def logo_thumb
    session[:logo_thumb]
  end

  def website_subdomain
    website_settings["subdomain"]
  end


end