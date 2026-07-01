require "./spec_helper"

describe Marten::SEO::PageMeta do
  it "initializes with empty json_ld and nested og/twitter holders" do
    meta = Marten::SEO::PageMeta.new
    meta.title.should be_nil
    meta.json_ld.should be_empty
    meta.og.type.should eq("website")
    meta.twitter.card.should eq("summary_large_image")
  end

  it "holds mutable scalar fields" do
    meta = Marten::SEO::PageMeta.new
    meta.title = "Home"
    meta.description = "Welcome"
    meta.canonical = "https://acme.test/"
    meta.robots = "noindex,nofollow"
    meta.og.image = "https://acme.test/og.png"
    meta.title.should eq("Home")
    meta.robots.should eq("noindex,nofollow")
    meta.og.image.should eq("https://acme.test/og.png")
  end

  it "accepts both string and hash json_ld nodes" do
    meta = Marten::SEO::PageMeta.new
    meta.json_ld << %({"@type":"Organization"})
    meta.json_ld << {"@type" => JSON::Any.new("WebSite")}
    meta.json_ld.size.should eq(2)
  end
end
