require "./spec_helper"

describe Marten::SEO::RobotsHandler do
  around_each do |example|
    original = Marten::SEO.config
    Marten::SEO.config = Marten::SEO::Config.new
    example.run
    Marten::SEO.config = original
  end

  it "emits configured rules and a sitemap line from base_url" do
    Marten::SEO.configure do |config|
      config.robots_user_agent = "*"
      config.robots_allow = ["/"]
      config.robots_disallow = ["/admin"]
      config.base_url = "https://acme.test"
    end

    response = Marten::Spec.client.get("/robots.txt")
    response.status.should eq(200)
    response.content_type.should eq("text/plain")

    body = response.content
    body.should contain("User-agent: *")
    body.should contain("Allow: /")
    body.should contain("Disallow: /admin")
    body.should contain("Sitemap: https://acme.test/sitemap.xml")
  end

  it "derives the sitemap host from the request when base_url is empty" do
    Marten::SEO.configure do |config|
      config.base_url = ""
      config.robots_disallow = [] of String
    end
    body = Marten::Spec.client.get("/robots.txt").content
    body.should match(/Sitemap: https?:\/\/[^\/\s]+\/sitemap\.xml/)
  end
end
