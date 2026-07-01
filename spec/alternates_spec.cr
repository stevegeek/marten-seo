require "./spec_helper"

describe "Marten::SEO.alternate_urls" do
  # Isolate config mutations so they don't bleed across examples.
  around_each do |example|
    original = Marten::SEO.config
    Marten::SEO.config = Marten::SEO::Config.new
    example.run
    Marten::SEO.config = original
  end

  it "maps every available locale to an absolute URL (kwargs form)" do
    urls = Marten::SEO.alternate_urls("about", base_url: "https://acme.test")
    urls.keys.sort.should eq(["en", "it"])
    # prefix_default_locale: false — default locale (en) is unprefixed, non-default (it) gets /it/.
    urls["en"].should eq("https://acme.test/about")
    urls["it"].should eq("https://acme.test/it/about")
  end

  it "strips a trailing slash from base_url" do
    urls = Marten::SEO.alternate_urls("about", base_url: "https://acme.test/")
    urls["it"].should eq("https://acme.test/it/about")
  end

  it "falls back to the configured base_url" do
    Marten::SEO.configure { |c| c.base_url = "https://configured.test" }
    urls = Marten::SEO.alternate_urls("home")
    # Default locale path is "/" (no prefix) → origin + "/" = one trailing slash.
    urls["en"].should eq("https://configured.test/")
  end

  it "accepts a params Hash (sitemap form)" do
    urls = Marten::SEO.alternate_urls("about", {} of String => String, "https://acme.test")
    urls["en"].should eq("https://acme.test/about")
  end
end
