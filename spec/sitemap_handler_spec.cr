require "./spec_helper"

describe Marten::SEO::SitemapHandler do
  around_each do |example|
    Marten::SEO::PageRegistry.clear
    original_config = Marten::SEO.config
    Marten::SEO.config = Marten::SEO::Config.new
    Marten::SEO.configure { |c| c.base_url = "https://acme.test" }
    example.run
    Marten::SEO.config = original_config
    Marten::SEO::PageRegistry.clear
  end

  it "emits a multi-locale urlset with hreflang alternates and x-default" do
    Marten::SEO::PageRegistry.register("about", priority: 0.8, changefreq: "monthly")
    response = Marten::Spec.client.get("/sitemap.xml")

    response.status.should eq(200)
    response.content_type.should eq("application/xml")
    body = response.content

    body.should contain(%(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"))
    # prefix_default_locale: false — English is /about (no prefix), Italian is /it/about
    body.should contain("<loc>https://acme.test/it/about</loc>")
    body.should contain("<loc>https://acme.test/about</loc>")
    body.should contain(%(<xhtml:link rel="alternate" hreflang="en" href="https://acme.test/about"/>))
    body.should contain(%(<xhtml:link rel="alternate" hreflang="it" href="https://acme.test/it/about"/>))
    # x-default points at the default-locale (en) URL
    body.should contain(%(<xhtml:link rel="alternate" hreflang="x-default" href="https://acme.test/about"/>))
    body.should contain("<changefreq>monthly</changefreq>")
    body.should contain("<priority>0.8</priority>")
  end

  it "includes dynamic registry entries with lastmod" do
    Marten::SEO::PageRegistry.register_dynamic do
      [Marten::SEO::SitemapEntry.new("about", changefreq: "daily", priority: 0.4, lastmod: "2026-07-01")]
    end
    body = Marten::Spec.client.get("/sitemap.xml").content
    body.should contain("<changefreq>daily</changefreq>")
    body.should contain("<lastmod>2026-07-01</lastmod>")
  end

  it "skips entries whose route cannot be reversed, continuing with good entries" do
    Marten::SEO::PageRegistry.register("about", priority: 0.9, changefreq: "weekly")
    Marten::SEO::PageRegistry.register("no_such_route_xyz")

    body = Marten::Spec.client.get("/sitemap.xml").content

    # Good entry is still rendered
    body.should contain("<loc>https://acme.test/about</loc>")
    # Bad entry is silently dropped — no crash, no loc for the missing route
    body.should_not contain("no_such_route_xyz")
  end

  it "restricts an entry to its declared locales" do
    Marten::SEO::PageRegistry.register("about", locales: ["en"])

    body = Marten::Spec.client.get("/sitemap.xml").content

    body.should contain("<loc>https://acme.test/about</loc>")
    body.should_not contain("<loc>https://acme.test/it/about</loc>")
    body.should_not contain(%(hreflang="it"))
    # en is the default locale, so x-default is still present and points at it
    body.should contain(%(<xhtml:link rel="alternate" hreflang="x-default" href="https://acme.test/about"/>))
  end

  it "omits x-default when the default locale is excluded, and supports dynamic entries" do
    Marten::SEO::PageRegistry.register_dynamic do
      [Marten::SEO::SitemapEntry.new("about", locales: ["it"])]
    end

    body = Marten::Spec.client.get("/sitemap.xml").content

    body.should contain("<loc>https://acme.test/it/about</loc>")
    body.should_not contain("<loc>https://acme.test/about</loc>")
    body.should_not contain("x-default")
  end
end
