require "marten"
require "./config"

module Marten
  module SEO
    # Emits robots.txt from the configured rules plus a `Sitemap:` line.
    class RobotsHandler < Marten::Handler
      def get
        respond(content: build_body, content_type: "text/plain")
      end

      private def build_body : String
        config = Marten::SEO.config
        base = config.base_url.empty? ? "#{request.scheme}://#{request.host}" : config.base_url
        String.build do |io|
          io << "User-agent: " << config.robots_user_agent << "\n"
          config.robots_allow.each { |path| io << "Allow: " << path << "\n" }
          config.robots_disallow.each { |path| io << "Disallow: " << path << "\n" }
          io << "\n"
          io << "Sitemap: " << base << "/sitemap.xml\n"
        end
      end
    end
  end
end
