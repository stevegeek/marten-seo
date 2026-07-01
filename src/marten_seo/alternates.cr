require "marten"

module Marten
  module SEO
    # Returns `locale => absolute URL` for a named route across all available
    # locales — for hreflang link tags, the sitemap, and language switchers.
    # `base_url` defaults to the configured `Marten::SEO.config.base_url`.
    def self.alternate_urls(route_name : String, base_url : String? = nil, **params) : Hash(String, String)
      hash = {} of String => String
      params.each { |key, value| hash[key.to_s] = value.to_s }
      alternate_urls(route_name, hash, base_url)
    end

    # :ditto: — Hash form, used by the sitemap where param keys are dynamic.
    def self.alternate_urls(route_name : String, params : Hash(String, String), base_url : String? = nil) : Hash(String, String)
      origin = (base_url || config.base_url).rstrip("/")

      reverse_params = {} of String | Symbol => Marten::Routing::Parameter::Types
      params.each { |key, value| reverse_params[key] = value }

      urls = {} of String => String
      I18n.available_locales.each do |locale|
        path = I18n.with_locale(locale) { Marten.routes.reverse(route_name, reverse_params) }
        urls[locale] = origin + path
      end
      urls
    end
  end
end
