require "./spec_helper"

describe Marten::SEO::Config do
  it "ships sane defaults" do
    config = Marten::SEO::Config.new
    config.default_robots.should eq("index,follow")
    config.robots_user_agent.should eq("*")
    config.robots_allow.should eq(["/"])
    config.robots_disallow.should be_empty
  end

  it "is mutated through Marten::SEO.configure and read via Marten::SEO.config" do
    Marten::SEO.configure do |c|
      c.site_name = "Acme"
      c.default_og_image = "https://acme.test/og.png"
      c.base_url = "https://acme.test/"
    end

    Marten::SEO.config.site_name.should eq("Acme")
    Marten::SEO.config.default_og_image.should eq("https://acme.test/og.png")
    # Trailing slash is stripped so URL joining never double-slashes.
    Marten::SEO.config.base_url.should eq("https://acme.test")
  end
end
