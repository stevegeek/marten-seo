require "./spec_helper"

describe Marten::SEO::RobotsHandler do
  around_each do |example|
    original = Marten::SEO.config
    Marten::SEO.config = Marten::SEO::Config.new
    example.run
    Marten::SEO.config = original
  end

  it "emits configured rules and a sitemap line from base_url" do
    Marten::SEO.configure do |c|
      c.robots_user_agent = "*"
      c.robots_allow = ["/"]
      c.robots_disallow = ["/admin"]
      c.base_url = "https://acme.test"
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
    Marten::SEO.configure do |c|
      c.base_url = ""
      c.robots_disallow = [] of String
    end
    body = Marten::Spec.client.get("/robots.txt").content
    body.should contain("Sitemap: ")
    body.should contain("/sitemap.xml")
  end
end
