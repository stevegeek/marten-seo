require "./spec_helper"

describe Marten::SEO::PageRegistry do
  before_each { Marten::SEO::PageRegistry.clear }

  it "registers static entries with metadata" do
    Marten::SEO::PageRegistry.register("home", priority: 1.0, changefreq: "weekly")
    Marten::SEO::PageRegistry.register("about", priority: 0.5, changefreq: "yearly")

    entries = Marten::SEO::PageRegistry.entries
    entries.size.should eq(2)
    entries.first.route_name.should eq("home")
    entries.first.priority.should eq(1.0)
    entries.first.changefreq.should eq("weekly")
  end

  it "carries reverse params and lastmod on an entry" do
    entry = Marten::SEO::SitemapEntry.new(
      "blog_post",
      params: {"slug" => "hello"},
      changefreq: "monthly",
      priority: 0.6,
      lastmod: "2026-07-01",
    )
    entry.params["slug"].should eq("hello")
    entry.lastmod.should eq("2026-07-01")
  end

  it "evaluates dynamic enumerators on every call to entries" do
    calls = 0
    Marten::SEO::PageRegistry.register_dynamic do
      calls += 1
      [Marten::SEO::SitemapEntry.new("blog_post", params: {"slug" => "a"})]
    end

    Marten::SEO::PageRegistry.entries.size.should eq(1)
    Marten::SEO::PageRegistry.entries.size.should eq(1)
    calls.should eq(2) # re-evaluated each time, so DB content stays fresh
  end

  it "orders static entries before dynamic ones" do
    Marten::SEO::PageRegistry.register("home")
    Marten::SEO::PageRegistry.register_dynamic do
      [Marten::SEO::SitemapEntry.new("blog_post", params: {"slug" => "z"})]
    end
    names = Marten::SEO::PageRegistry.entries.map(&.route_name)
    names.should eq(["home", "blog_post"])
  end
end
